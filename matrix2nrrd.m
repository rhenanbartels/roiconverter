function matrix2nrrd(outputName, img, metadata)

    voxelDimensions  = metadata.PixelSpacing;
    voxelDimensions(end + 1) = metadata.SliceThickness;
    
    origin = metadata.ImagePositionPatient;
    
    nrrdWriter(outputName, img, voxelDimensions, origin, 'raw');
    
end