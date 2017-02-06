function roiconverter(folderPath, ext)

    if nargin == 1
        ext = '.nrrd';
    end
    
    if ~strcmp(ext, '.nrrd')
        error('This version only supports NRRD extension.');
    end
    
    initDependencies();

    [metadatas, img] = opendicoms(folderPath);
    
    if ~isempty(metadatas) && ~isempty(img)
        
        lungRoi = getroiinfo(metadatas);
        
        %prepare folder and file names
        [resultsFolder, imgFileName, roiFileName] =...
            createOutputFileAndFolderName(folderPath, metadatas, ext);
        
        mkdir(resultsFolder)
        
        %save images
        matrix2nrrd(imgFileName, img, metadatas{1})
        
        if any(sum(sum(lungRoi)))
            matrix2nrrd(roiFileName, lungRoi, metadatas{1})
        end
    else
        disp('No DICOMS file found!');
    end
    
end

function [resultsFolder, imgFileName, roiFileName] =...
    createOutputFileAndFolderName(folderPath, metadata, ext)

    if strcmp(folderPath(end), filesep)
        resultsFolder = [folderPath 'ConversionOutput'];
        
    else
        resultsFolder = [folderPath filesep 'ConversionOutput'];
    end
   
    imgFileName = [resultsFolder filesep 'dicom' ext];
    roiFileName = [resultsFolder filesep 'roi' ext];
    
end

function initDependencies()
    addpath('external/');
end