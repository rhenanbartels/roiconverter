function roiconverter(folderPath, ext)

    if nargin == 1
        ext = '.nrrd';
    end

    [metadatas, img] = opendicoms(folderPath);
    lungRoi = getroiinfo(metadatas);
    
    %prepare folder and file names
    [resultsFolder, imgFileName, roiFileName] =...
        createOutputFileAndFolderName(folderPath, metadatas, ext);
    
    mkdir(resultsFolder)
    
    %save images
    matrix2nrrd(imgFileName, img, metadatas{1})
    matrix2nrrd(roiFileName, lungRoi, metadatas{1})
    
   
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