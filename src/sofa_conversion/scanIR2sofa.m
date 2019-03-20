%.  scanIR2sofa
%.  
%.  6 JAN 2019
%. 
%.  scanIR2sofa writes the data and procedures of a ScanIR session to a
%.  .sofa file.
%. 
%.  arguments:
%.      - app, data, specs are resultant structs from ScanIR v1.2 or
%.        higher.
%.
%.  scanIR2sofa(READ_FILENAME) writes a .sofa file of measurement
%.  session data contained in the ScanIR output .mat file READ_FILENAME.
%.
%.  scanIR2sofa(READ_FILENAME, IS_ADVANCED_SAVE) writes a .sofa file
%.  of measurement session data contained in the ScanIR output .mat
%.  file. If IS_ADVANCED_SAVE has value "true" a dialog window is shown
%.  which permits manual entry of certain SOFA fields.
%. 
%.  scanIR2sofa(APP, DATA, SPECS, WRITE_FILENAME, IS_ADVANCED_SAVE)
%.  converts a session already loaded to the MATLAB Workspace.
%.  
%.
%.  Written by Julian Vanasse
%.  NYU Music and Audio Research Lab
%.  Copyright 2019

%. NOTES:
%. - include argument bool for "where to save", and if true prompt for
%    location, but if not just save in local directory
%  - multiple versions for internal vs external use
%  - user change room type?
%
% MULTIPLE VERSIONS:
%   - if varargin == 2 -> just read_filename and isAdvancedSave
%   - if varargin == 5 -> app, data, specs, write_filename, isAdvancedSave
%function scanIR2sofa(app, data, specs, filename, isBRIR, isAdvancedSave)
function scanIR2sofa(varargin)
    
    read_filename       = [];
    write_filename      = [];
    isAdvancedSave      = [];
    app                 = [];
    data                = [];
    specs               = [];   

    if nargin == 1
        read_filename   = varargin{1};
        isAdvancedSave  = false;
        load(read_filename, '-mat', 'app', 'data', 'specs');
    elseif nargin == 2
        read_filename   = varargin{1};
        isAdvancedSave  = varargin{2};
        load(read_filename, '-mat', 'app', 'data', 'specs');
    elseif nargin == 5
        app             = varargin{1};
        data            = varargin{2};
        specs           = varargin{3};
        write_filename  = varargin{4};
        isAdvancedSave  = varargin{5};
    else
        error('Incorrect number of arguments. See help scanIR2sofa');
    end
    
    if isempty(write_filename)
        [~, write_filename, ~]   = fileparts(read_filename);
        write_filename           = strcat(write_filename, '.sofa');
    end

    SOFAstart;
    
    % check to ensure arguments are valid
    scanIR2sofa_check_arguments(app, data, specs, write_filename);
    
    Obj = [];
    if app.isBRIR
        Obj = SOFAgetConventions('MultiSpeakerBRIR');
    else 
        Obj = SOFAgetConventions('GeneralFIR');
    end

    % malloc 
    % --- M = number of measurements
    % --- N = length of measurement (i.e. length in samples)
    % --- R = number of receivers
    % --- C = number of coordinates
    [~, M] = size(data);
    N = app.irLength;
    R = app.numInputChls;
    C = 3;
    
    Obj.Data.Delay = zeros(M,R);
    Obj.ReceiverPosition = zeros(R,C,M); 
    Obj.SourcePosition = zeros(M,C);
    
    % allocate space for IRs with dimension [M by R by N]
    Obj.Data.IR = NaN(M,R,N);
    Obj.Data.SamplingRate = specs.sampleRate;
    Obj.SourcePosition_Type = 'horizontal';
    
    % fill Obj.Data.IR with IR data from tempData (ScanIR return) and store
    % azimuthal and elivation angles
    for i = 1:M
        % --- place IRs --- %
        measure = data(i);
        measure.IR = permute(measure.IR(:,:,1), ...
            [3,2,1]);
        Obj.Data.IR(i, :, :) = measure.IR;
        
        % --- place azimuthal, elevation and distance data --- %
        Obj.SourcePosition(M,:) = [measure.azimuth, ...
            measure.elevation, measure.distance];
        Obj.ReceiverPosition(:, :, M) = [0,0,0];
    end  
    clearvars('measure');
    
    % place information regarding signal type, etc in GLOBAL_Comment
    %   see populateComments(specs) below 
    Obj.GLOBAL_Comment = populateComments(specs, app);
    
    if isAdvancedSave
        sofa_scanIR_tokens;
        args_out = AdvancedSaveOptions; 
        Obj.GLOBAL_Comment = strcat(Obj.GLOBAL_Comment, ...
            COMMENTS_TAG, args_out.comment);
        Obj.GLOBAL_AuthorContact = args_out.authorContact;
        Obj.GLOBAL_Organization = args_out.organization;
        Obj.GLOBAL_DatabaseName = args_out.databaseName;
    end
    
    compression = 1;
    SOFAsave(write_filename, Obj, compression);
end

function comments_str = populateComments(specs, app)
    sofa_scanIR_tokens;
    comments_str = [];
    comments_str = sprintf(strcat(comments_str, MARL_TAG, newline));
    comments_str = sprintf(strcat(comments_str, strcat(SIGNAL_TYPE, ...
        specs.signalType, ', ')));
    comments_str = sprintf(strcat(comments_str, strcat(SIGNAL_DUR, ...
        app.sigLength, ',')));
    comments_str = sprintf(strcat(comments_str, strcat(FILTER_TYPE, ...
        specs.filtertype, ', ')));
    
end

function scanIR2sofa_check_arguments(app, data, specs, ...
    write_filename)
    %{
        Checks that app, data and specs are the correct format
    %}
    if ~isstruct(app)
        error('app must be a struct');
    elseif ~isstruct(data)
        error('data must be a struct');
    elseif ~isstruct(specs)
        error('specs must be a struct');
    end

    % --- check filename has proper suffix 
    if ~checkSuffix(write_filename), error('filename must end in \".sofa\"'); end     

end


function tf = checkSuffix(str)
    if strcmp(str(end-4:end), '.sofa'), tf = 1; 
    else, tf = 0; end;
end