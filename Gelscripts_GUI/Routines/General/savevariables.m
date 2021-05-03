function savevariables(sfname, type, varargin)

if strcmp(type,'prep')
    Initial_binarization = varargin{1,1};
    Processed_binarization = varargin{1,2};
    save(sfname,'Initial_binarization','Processed_binarization')
elseif strcmp(type,'skel')
    Skeleton = varargin{1,1};
    Nodelist = varargin{1,2};
    Linklist = varargin{1,3};
	save(sfname,'Skeleton', 'Nodelist', 'Linklist')
elseif strcmp(type,'ana')
    ii = varargin{1,1};
    Tortuosity_data = varargin{1,2}(ii,:);
    Linklength_distribution = [varargin{1,3}(:,1),varargin{1,3}(:,2)];
    Node_number = varargin{1,4}(1,ii);
    Link_number = varargin{1,5}(1,ii);
    Node_density = varargin{1,6}(1,ii);    
    Link_density = varargin{1,7}(1,ii);
    Links_per_node = varargin{1,8}(1,ii);
	Tortuosities_xyz = varargin{1,9}(ii,:);
    if size(varargin,2) > 9
        Pathlengths_x = varargin{1,10};
        Pathlengths_y = varargin{1,11};
        Pathlengths_z = varargin{1,12};
        Eucl_dists_x = varargin{1,13};
        Eucl_dists_y = varargin{1,14};
        Eucl_dists_z = varargin{1,15};
        Individ_tort_x = varargin{1,16};
        Individ_tort_y = varargin{1,17};
        Individ_tort_z = varargin{1,18};        
        save(sfname,'Tortuosity_data', 'Tortuosities_xyz', 'Pathlengths_x',...
            'Pathlengths_y','Pathlengths_z','Eucl_dists_x','Eucl_dists_y',...
            'Eucl_dists_z','Individ_tort_x','Individ_tort_y','Individ_tort_z',...
            'Linklength_distribution','Node_number','Link_number','Node_density',...
            'Link_density', 'Links_per_node')
    else
        save(sfname,'Tortuosity_data', 'Linklength_distribution','Node_number',...
        'Link_number', 'Node_density', 'Link_density', 'Links_per_node')
    end
end
