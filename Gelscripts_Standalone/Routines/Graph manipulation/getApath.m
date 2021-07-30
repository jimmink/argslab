function Apath = getApath(node,link,sizes,realpx)
% GETAPATH is a wrapper around LENGTH3DPATHSKEL and calculated the 
% distance for each link, weighted by the asymmetry of voxels.

Apath = zeros(size(node,2));

for i=1:length(Apath) 
    idx1=find(node(i).conn>0); 
    idx2=find(node(i).links>0); 
    idx=intersect(idx1,idx2); 
    for j=1:length(idx) 
        if(i==link(node(i).links(idx(j))).n1) 
            Apath(i,link(node(i).links(idx(j))).n2)=length3DpathSkel(link,sizes,i,node,idx(j),realpx); 
            Apath(link(node(i).links(idx(j))).n2,i)=length3DpathSkel(link,sizes,i,node,idx(j),realpx); 
        end
        if(i==link(node(i).links(idx(j))).n2) 
            Apath(i,link(node(i).links(idx(j))).n1)=length3DpathSkel(link,sizes,i,node,idx(j),realpx); 
            Apath(link(node(i).links(idx(j))).n1,i)=length3DpathSkel(link,sizes,i,node,idx(j),realpx); 
        end
    end
end