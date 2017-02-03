function roi = getroiinfo(metadatas)
      nSlices = length(metadatas);
     
      roi = cell(1, nSlices);
     
      for k = 1:nSlices
          metadata = metadatas{k};
          
          if isfield(metadata, 'Private_6001_10c0')
              roi_info = metadata.Private_6001_10c0.Item_1;
              count = 1;
              fields = fieldnames(roi_info);
              
              for l=1:length(fields)
                  f = fields{l};
                  
                  if ~isempty(strfind(f, '_10b0'))
                      
                      if strcmp(roi_info.(f), 'POLYGON')
                          ind = textscan(f,'%s','delimiter','_');
                          poly_roi = roi_info.(strcat(ind{1}{1},'_',...
                              ind{1}{2}, '_10ba'));
                          roi{k}{count} = [poly_roi(1:2:end-1)...
                              poly_roi(2:2:end-1)];
                          count = count+1;
                      end
                  end
              end
          end
      end
      
      nRows = double(metadatas{1}.Rows);
      nCols = double(metadatas{1}.Columns);
      
      roi = convertROItoMask(roi, nRows, nCols, nSlices);
end

function mask_lung = convertROItoMask(ct_roi, nRows, nCols, nSlices)

    counter = 1;
    mask_lung = zeros(nRows, nCols, nSlices);
    polygon_lung_original= cell(1, nSlices);
    
    for k= 1:nSlices
        polygon_lung_original{counter} = ct_roi{k};
        m = mask_lung(:, :, counter);
        for n = 1:length(ct_roi{k})
            m2 = poly2mask(double(ct_roi{k}{n}(:,1)),...
                double(ct_roi{k}{n}(:,2)),...
                nRows,...
                nCols);
            m(m2) = 1;
        end
        mask_lung(:, :, counter) = m;
        counter = counter + 1;
    end
end