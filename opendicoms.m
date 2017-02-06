function [metadata, img] = opendicoms(folderPath)
    fileAndFolders = dir(folderPath);
    dicomNames = getDicomFileNames(folderPath, fileAndFolders);
    
    metadata = {};
    img = {};
    
    if ~isempty(dicomNames)
        [metadata, img] = readDicoms(dicomNames);
    end
end

function [metadata, img] = readDicoms(dicomNames)
    nSlices = length(dicomNames);
    [nRows,nCols] = getDicomDim(dicomNames{1});
 
    img = zeros(nRows, nCols, nSlices); 
    metadata = cell(1, nSlices);
    
    
    for i = 1:nSlices
        metadata{i} = dicominfo(dicomNames{i});
        img(:, :, i) = dicomread(dicomNames{i});
    end

end

function [nRows,nCols] = getDicomDim(dicomName)
    metadata = dicominfo(dicomName);
    nRows = metadata.Rows;
    nCols = metadata.Columns;
end

function dicomNames = getDicomFileNames(folderPath, fileAndFolders)
    nItems = length(fileAndFolders);
    
    counter = 1;
    
    
    dicomNames = {};
    for i = 1:nItems        
        name = fileAndFolders(i).name;
        fullName = [folderPath filesep name];       
        if isDicom(fullName)
            dicomNames{counter} = fullName;
            counter = counter + 1;
        end
        
    end
end


function flag = isDicom(pathName)
    %Deal with dicom files without extension
    flag = 0;
    try
        dicominfo(pathName);
        flag = 1;
    catch
    end
end