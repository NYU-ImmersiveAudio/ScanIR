function [handles] = displayFields(handles)

% Populate the fields of the GUI
idx = handles.app.currID;


chl = get(handles.chl_popup,'Value')-1;
if chl == 0
    disp('Displaying average analysis metrics for all channels')
    set(handles.param_chl,'String','Multi-channel averages','ForegroundColor','k');
    if handles.app.inMode == 1
        set(handles.param_chl,'String','Channel 1','ForegroundColor',handles.colors(1,:));
    end
    set(handles.param_RT60,'String',[num2str(mean(handles.data(idx).RT60(~isnan(handles.data(idx).RT60)))),' s']);
    set(handles.param_RT30,'String',[num2str(mean(handles.data(idx).RT30(~isnan(handles.data(idx).RT30)))),' s']);
    set(handles.param_RT20,'String',[num2str(mean(handles.data(idx).RT20(~isnan(handles.data(idx).RT20)))),' s']);
    set(handles.param_EDT,'String',[num2str(mean(handles.data(idx).EDT(~isnan(handles.data(idx).EDT)))),' s']);
    set(handles.param_D50,'String',[num2str(mean(handles.data(idx).D50(~isnan(handles.data(idx).D50))))]);
    set(handles.param_C80,'String',[num2str(mean(handles.data(idx).C80(~isnan(handles.data(idx).C80))))]);
    set(handles.param_C50,'String',[num2str(mean(handles.data(idx).C50(~isnan(handles.data(idx).C50))))]);
    set(handles.param_DRR,'String',[num2str(mean(handles.data(idx).DRR(~isnan(handles.data(idx).DRR))))]);
    set(handles.param_TS,'String',[num2str(1000*mean(handles.data(idx).TS(~isnan(handles.data(idx).TS)))),' ms']);
    set(handles.param_ITDG,'String',[num2str(1000*mean(handles.data(idx).ITDG(~isnan(handles.data(idx).ITDG)))),' ms']);
    
else
    disp(['Displaying analysis for channel ',num2str(chl)]);
    if chl <= size(handles.colors,1)
        c = handles.colors(chl,:);
    else
        c = rand(1,3);
    end
    set(handles.param_chl,'String',['Channel ',num2str(chl)],'ForegroundColor',c);
    set(handles.param_RT60,'String',[num2str(handles.data(idx).RT60(chl)),' s']);
    set(handles.param_RT30,'String',[num2str(handles.data(idx).RT30(chl)),' s']);
    set(handles.param_RT20,'String',[num2str(handles.data(idx).RT20(chl)),' s']);
    set(handles.param_EDT,'String',[num2str(handles.data(idx).EDT(chl)),' s']);
    set(handles.param_D50,'String',[num2str(handles.data(idx).D50(chl))]);
    set(handles.param_C80,'String',[num2str(handles.data(idx).C80(chl))]);
    set(handles.param_C50,'String',[num2str(handles.data(idx).C50(chl))]);
    set(handles.param_DRR,'String',[num2str(handles.data(idx).DRR(chl))]);
    set(handles.param_TS,'String',[num2str(1000*handles.data(idx).TS(chl)),' ms']);
    set(handles.param_ITDG,'String',[num2str(1000*handles.data(idx).ITDG(chl)),' ms']);
end

if handles.app.inMode ~= 2
    set(handles.param_ITD,'String','n/a');
    set(handles.param_ILD,'String','n/a');
    set(handles.param_IACC,'String','n/a');
else
    set(handles.param_ITD,'String',[num2str(1000*handles.data(idx).ITD),' ms']);
    set(handles.param_ILD,'String',[num2str(handles.data(idx).ILD),' dB']);
    set(handles.param_IACC,'String',[num2str(handles.data(idx).IACC)]);
end

end

