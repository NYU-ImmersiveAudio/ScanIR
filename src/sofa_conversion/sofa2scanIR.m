%.  sofa2scanIR
%.
%.  6 JAN 2019
%.
%.  This function ensures backwards compatibility with older versions of
%.  ScanIR. Files of type .sofa can be loaded to ScanIR to continue
%.  measurements.
%. 
%.  [APP, DATA, SPECS] = sofa2scanIR(SOFA_FILENAME) returns the ScanIR
%.  session data in the ScanIR format of 3 structs: APP, DATA and SPECS.
%.  
%.  Written by Julian Vanasse
%.  NYU Music and Audio Research Lab
%.  Copyright 2019

function [app, data, specs] = sofa2scanIR(sofa_filename)
    
    app     = [];
    data    = [];
    specs   = [];
    
    data.IR         = [];
    data.azimuth    = [];
    data.elevation  = [];
    data.distance   = [];
    data.ITD        = [];
    data.comments   = [];
    
    specs.filterType    = [];
    specs.subjectName   = [];
    specs.database      = [];
    specs.comments      = [];
    specs.signalType    = [];
    specs.sampleRate    = [];
    
    app.currID          = [];
    app.npositions      = [];
    app.sorted          = [];
    app.azPositionData  = [];
    app.elPositionData  = [];
    app.seriesInfo      = [];
    app.isBRIR          = [];
    app.inMode          = [];
    app.sigLength       = [];
    app.irLength        = [];
    app.numInputChls    = [];
    app.numOutputChls   = [];
    app.outMode         = [];
    app.numPlays        = [];
    app.outchl          = [];
    
    Obj = SOFAload(sofa_filename);
    
    for measurement = 1:Obj.API.M
        data(measurement).IR = Obj.Data.IR(measurement, :, :);
        data(measurement).IR = permute(data(measurement).IR, ...
            [3,2,1]);
        if (strcmp(Obj.SourcePosition_Type, 'horizontal'))
            % extract source position for 'measurement'
            pos = Obj.SourcePosition(measurement, :, :);
            data(measurement).azimuth   = pos(1);
            data(measurement).elevation = pos(2);
            data(measurement).distance  = pos(3);
        end
        data(measurement).ITD = 0; % is NaN better?
        data(measurement).comments = [];
    end
    
    % decode comments section of Obj
    [app, data, specs]  = sofa2scanIR_interpretComments(Obj, app, data, specs);
    
    specs.database      = Obj.GLOBAL_DatabaseName;
    specs.sampleRate    = Obj.Data.SamplingRate;
    
    app.currID          = 1;
    app.npositions      = Obj.API.M;
    app.sorted          = 0;
    app.numInputChls    = Obj.API.R; 
    app.isBRIR          = 0;
    
    % ScanIR modes (app.inMode):
    %   1   - mono IR
    %   2   - BRIR or HRTF
    %   3   - multichannel IR
    if (strcmp(Obj.GLOBAL_SOFAConventions, 'GeneralFIR'))
        if (Obj.API.R == 1)
            app.inMode = 1;
        else
            app.inMode = 3;
        end
    elseif (strcmp(Obj.GLOBAL_SOFAConventions,'MultiSpeakerBRIR'))
        app.inMode = 2;
        app.isBRIR = 1;
    else
        error('SOFA file cannot be opened by ScanIR');
    end
    
end

function [app, data, specs] = sofa2scanIR_interpretComments(Obj, app, data, specs);
    sofa_scanIR_tokens;
    comments = Obj.GLOBAL_Comment; 
    
    % check if Obj.GLOBAL_Comment contains ScanIR metadata
    
    % check for Signal Type field
    if (contains(comments, SIGNAL_TYPE))
        k = strfind(comments, SIGNAL_TYPE);
        k = k + length(SIGNAL_TYPE);
        specs.signalType = comments(k:strfind(comments, SIGNAL_DUR)-2);
    else
        fprintf('\t specs.signalType was not recovered');
    end 
    
    if (contains(comments, SIGNAL_DUR))
        k = strfind(comments, SIGNAL_DUR);
        k = k + length(SIGNAL_DUR);
        app.sigLength = comments(k:strfind(comments, FILTER_TYPE)-2);
    else
        fprintf('\t app.sigLength was not recovered');
    end
    
    % check for Filter Type field
    if (contains(comments, FILTER_TYPE))
        k = strfind(comments, FILTER_TYPE);
        k = k + length(FILTER_TYPE);
        specs.filterType = comments(k:strfind(comments, COMMENTS_TAG)-2);
    else
        fprintf('\t specs.filterType was not recovered');
    end
    
    % check for further comments
    if (contains(comments, COMMENTS_TAG))
        k = strfind(comments, COMMENTS_TAG);
        k = k + length(COMMENTS_TAG);
        specs.comments = comments(k:end);
    end
end