function roiconverter()

    initDependencies();

    createInterface();
    
    

    
end

function convert(hObject, eventdata)
    handles = guidata(hObject);
    
    folderPath = handles.folderPath;

    logTextArea(handles.textArea, 'Verarbeitet...');
    [metadatas, img] = opendicoms(folderPath);
    
    if ~isempty(metadatas) && ~isempty(img)
        ext = '.nii';
        
        lungRoi = getroiinfo(metadatas);
        
        %prepare folder and file names
        [resultsFolder, imgFileName, roiFileName] =...
            createOutputFileAndFolderName(folderPath, metadatas, ext);
        
        mkdir(resultsFolder)
        
        %Uncalibrate Lung if necessary (negative HU values)
        if min(min(min(img))) < 0
            img = uncalibrateLung(img, metadatas{1});
        end
        
        %save images       
        exportNfti(imgFileName, uint16(img), metadatas{1})
        
        if any(sum(sum(lungRoi)))            
            exportNfti(roiFileName, uint16(lungRoi), metadatas{1})
        end
        
    logTextArea(handles.textArea, ['DICOMS in ' resultsFolder ' gespeichert!']);    
    
    else
        logTextArea(handles.textArea, 'DICOMS nicht gefunden');
    end
end

function img = uncalibrateLung(img, metadata)
    
        img = (img - metadata.RescaleIntercept) / metadata.RescaleSlope;
    
end

function exportNfti(fileName, matrix, metadata)
    matrix = imrotate(matrix, -90);
    voxelSize = [metadata.PixelSpacing; metadata.SliceThickness];
    origin = metadata.ImagePositionPatient;
    nii = make_nii(matrix, voxelSize, origin);
    save_nii(nii, fileName);
end

function exportNRRD(fileName, matrix, metadata)
    dataTypes = {'int16', 'uint16', 'int32', 'uint32',...
        'int64','uint64', 'double', 'int8', 'uint8'};
    
    for dtype = dataTypes;
        func = str2func(dtype{1});
        convertedMatrix = func(matrix);
        matrix2nrrd(fileName, convertedMatrix, metadata);
        try
            nrrdReader(fileName);
            return
        catch
        end
    end


end

function logTextArea(handle, msg, flush)
    if nargin < 3
        flush = 0;
    end
    if flush
        set(handle, 'String', '')
    else
        set(handle, 'String', msg);
       drawnow
    end
end


function getRootFolder(hObject, eventdata)
    handles = guidata(hObject);
    
    if ~isfield(handles, 'folderPath');
        folderPath = uigetdir('W�hlen Sie einen Ordner ');
    else
       folderPath = uigetdir(handles.folderPath,...
           'W�hlen Sie einen Ordner '); 
    end
    
    if folderPath
        
        set(handles.txtRootFolder, 'String', folderPath);
        set(handles.btnDoIt, 'Enable', 'On')
        handles.folderPath = folderPath;
        guidata(hObject, handles);
    end
end

function createInterface()
    fig = figure('Menubar', 'None',...
        'Name', 'ROI Converter',...
        'NumberTitle', 'Off');
    figPosition = get(fig, 'Position');
    figPosition(3) = figPosition(1) * 1.6;
    figPosition(4) = figPosition(2) * 0.7;
    set(fig, 'Position', figPosition);
    bckColor = get(fig, 'Color');
    
    uicontrol('Parent', fig,...
        'String', 'Ordner w�hlen',...
        'Units', 'Normalized',...
        'Position', [0.01, 0.6, 0.165, 0.2],...
        'Callback', @getRootFolder);
    uicontrol('Parent', fig,...
        'String', '',...
        'Style', 'Edit',...
        'Units', 'Normalized',...
        'Position', [0.18, 0.6, 0.8, 0.2],...
        'Backgroundcolor', [1 1 1],...
        'Tag', 'txtRootFolder')
    
    uicontrol('Parent', fig,...
        'String', 'Hauptordner',...
        'Style', 'Text',...
        'Units', 'Normalized',...
        'Position', [0.43, 0.82, 0.2, 0.15],...
        'Backgroundcolor', bckColor,...
        'Fontweight', 'bold')
    
    
    uicontrol('Parent', fig,...
        'String', 'Auf geht''s',...
        'Units', 'Normalized',...
        'Position', [0.46, 0.32, 0.12, 0.25],...
        'Enable', 'Off',...
        'Callback', @convert,...
        'Tag', 'btnDoIt');
        
    uicontrol('Parent', fig,...
        'String', 'Log:',...
        'Style', 'Text',...
        'Units', 'Normalized',...
        'Position', [0.025, 0.02, 0.98, 0.3],...
        'Backgroundcolor', bckColor,...
        'HorizontalAlignment', 'Left',...
        'Tag', 'textArea')   

    
    handles = guihandles(fig);
    
    handles.hyper = [-1000, -901];
    handles.normally = [-901, -501];
    handles.poorly = [-500, -101];
    handles.non = [-100, 100];
    
    guidata(fig, handles);
end

function [resultsFolder, imgFileName, roiFileName] =...
    createOutputFileAndFolderName(folderPath, metadata, ext)

    if strcmp(folderPath(end), filesep)
        resultsFolder = [folderPath 'ConversionOutput'];
        
    else
        resultsFolder = [folderPath filesep 'ConversionOutput'];
    end
   
    imgFileName = [resultsFolder filesep 'dicom' ext '.gz'];
    roiFileName = [resultsFolder filesep 'roi' ext '.gz'];
    
end


function initDependencies()
    addpath('external/');
end