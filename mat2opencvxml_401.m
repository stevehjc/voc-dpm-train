function mat2opencvxml_401(matmodel, xmlfile)
% 有问题，和voc-release5版本不兼容

% matmodel = 'sofa_final';
% xmlfile = 'sofa_final.xml';

load(matmodel);
fid = fopen(xmlfile, 'w');

fprintf(fid, '<Model>\n');

ncom = length(model.rules{model.start});
fprintf(fid, '\t<!-- Number of components -->\n');
fprintf(fid, '\t<NumComponents>%d</NumComponents>\n', ncom);

nfeature = 31;
fprintf(fid, '\t<!-- Number of features -->\n');
fprintf(fid, '\t<P>%d</P>\n', nfeature);

fprintf(fid, '\t<!-- Score threshold -->\n');
fprintf(fid, '\t<ScoreThreshold>%.16f</ScoreThreshold>\n', model.thresh);
layer = 1;
for icom = 1:ncom
    fprintf(fid, '\t<Component>\n');
    
        fprintf(fid, '\t\t<!-- Root filter description -->\n');
        fprintf(fid, '\t\t<RootFilter>\n');
        
            % attention: X,Y swap
            rhs = model.rules{model.start}(icom).rhs;
            % assume the root filter is first on the rhs of the start rules
            if model.symbols(rhs(1)).type == 'T'
              % handle case where there's no deformation model for the root
              root = model.symbols(rhs(1)).filter;
            else
              % handle case where there is a deformation model for the root
              root = model.symbols(model.rules{rhs(1)}(layer).rhs).filter;
            end
            
            filternum = root;
            sizeX = model.filters(filternum).size(2);
            sizeY = model.filters(filternum).size(1);
            fprintf(fid, '\t\t\t<!-- Dimensions -->\n'); 
            fprintf(fid, '\t\t\t<sizeX>%d</sizeX>\n', sizeX); 
            fprintf(fid, '\t\t\t<sizeY>%d</sizeY>\n', sizeY);
        
            fprintf(fid, '\t\t\t<!-- Weights (binary representation) -->\n');
            fprintf(fid, '\t\t\t<Weights>');
            for iY = 1:sizeY
                for iX = 1:sizeX
                    % original mat has 32 which is larger than nfeature=31 by 1
                    fwrite(fid, model.filters(filternum).w(iY,iX,1:nfeature), 'double'); % need verify
                end
            end
            fprintf(fid, '\t\t\t</Weights>\n');
            
    		
            fprintf(fid, '\t\t\t<!-- Linear term in score function -->\n');
            fprintf(fid, '\t\t\t<LinearTerm>%.16f</LinearTerm>\n', ...  % need verify
                model.rules{model.start}(icom).offset.w);
            
        fprintf(fid, '\t\t</RootFilter>\n');
        
        fprintf(fid, '\t\t<!-- Part filters description -->\n');
        fprintf(fid, '\t\t<PartFilters>\n');
        
        npart = length(model.rules{model.start}(icom).rhs) -1 ;
        fprintf(fid, '\t\t\t<NumPartFilters>%d</NumPartFilters>\n', npart);
        
        for ipart = 2: npart+1
            fprintf(fid, '\t\t\t<!-- Part filter ? description -->\n');
            fprintf(fid, '\t\t\t<PartFilter>\n');
            
            irule = model.rules{model.start}(icom).rhs(ipart);
            filternum = model.symbols(model.rules{irule}.rhs).filter;
            sizeX = model.filters(filternum).size(2);
            sizeY = model.filters(filternum).size(1);
            fprintf(fid, '\t\t\t\t<sizeX>%d</sizeX>\n', sizeX);
            fprintf(fid, '\t\t\t\t<sizeY>%d</sizeY>\n', sizeY);
            fprintf(fid, '\t\t\t\t<!-- Weights (binary representation) -->\n');
            fprintf(fid, '\t\t\t\t<Weights>');
            for iY = 1:sizeY
                for iX = 1:sizeX
                    % original mat has 32 which is larger than nfeature=31 by 1
                    fwrite(fid, model.filters(filternum).w(iY,iX,1:nfeature), 'double'); % need verify
                end
            end
            fprintf(fid, '\t\t\t\t</Weights>\n');
            
            fprintf(fid, '\t\t\t\t<!-- Part filter offset -->\n');
            
            fprintf(fid, '\t\t\t\t<V>\n');
            
            fprintf(fid, '\t\t\t\t\t<Vx>%d</Vx>\n',model.rules{model.start}(icom).anchor{ipart}(1)+1); %[dx,dy,ds]
            fprintf(fid, '\t\t\t\t\t<Vy>%d</Vy>\n',model.rules{model.start}(icom).anchor{ipart}(2)+1);
            
            fprintf(fid, '\t\t\t\t</V>\n');
            
            
            fprintf(fid, '\t\t\t\t<!-- Quadratic penalty function coefficients -->\n');
            
            fprintf(fid, '\t\t\t\t<Penalty>\n');
            fprintf(fid, '\t\t\t\t\t<dx>%.16f</dx>\n',model.rules{irule}.def.w(2)); 
            fprintf(fid, '\t\t\t\t\t<dy>%.16f</dy>\n',model.rules{irule}.def.w(4)); 
            fprintf(fid, '\t\t\t\t\t<dxx>%.16f</dxx>\n',model.rules{irule}.def.w(1)); 
            fprintf(fid, '\t\t\t\t\t<dyy>%.16f</dyy>\n',model.rules{irule}.def.w(3)); 
            
            fprintf(fid, '\t\t\t\t</Penalty>\n');
				
            
            
            fprintf(fid, '\t\t\t</PartFilter>\n');
        end
    
        fprintf(fid, '\t\t</PartFilters>\n');
    fprintf(fid, '\t</Component>\n');
end
fprintf(fid, '</Model>\n');
fclose(fid);

end