function PlotLine(point,number,type)
switch type
    case 1 % plot cluster
        for i = 1:number
            linex = point(:,2*i-1);
            linex(linex(:)==0) = [];
            l = length(linex);                 
            plot(point(1:l,2*i-1),point(1:l,2*i),'k.','markersize',3); hold on            
            plot(point(1,2*i-1),point(1,2*i),'ro');
            plot(point(l,2*i-1),point(l,2*i),'bo');
        end
    
    case 2 % plot line segment
        for j = 1:number            
            plot(point(:,2*j-1),point(:,2*j),'k-','LineWidth',1);hold on
        end
        
    case 3
        for k = 1:number            
            plot(point(:,2*k-1),point(:,2*k),'k-','LineWidth',2);hold on
        end 
        
    case 4
        shiftclass = number;
        shiftrest = point;
        totalclass = max(shiftclass(:)); % 共多少集合
        totalline = size(shiftclass,2);
        color = rand(totalclass,3);
        for i = 1 : totalclass
            for j = 1 : totalline
                if shiftclass(j) == i
                    plot([shiftrest(1,2*j-1);shiftrest(2,2*j-1)],...
                        [shiftrest(1,2*j);shiftrest(2,2*j)],...
                        'linewidth',3,'color',color(i,:));
                    hold on
                end
            end
        end
        
    case 5
        shiftclass = number;
        shiftrest = point;
        totalclass = max(shiftclass(:)); % 共多少集合
        totalline = size(shiftclass,2);
        color = rand(totalclass,3);
        subplot(1,2,1)
        for i = 1 : totalclass
            for j = 1 : totalline
                if shiftclass(j) == i
                    plot([shiftrest.point(1,2*j-1);shiftrest.point(2,2*j-1)],...
                        [shiftrest.point(1,2*j);shiftrest.point(2,2*j)],...
                        'linewidth',3,'color',color(i,:));
                    hold on
                end
            end
        end
        subplot(1,2,2)
        for i = 1 : totalclass
            for j = 1 : totalline
                if shiftclass(j) == i
                    plot(shiftrest.decision(1,j),shiftrest.decision(2,j),'*',...
                        'markersize',3,'color',color(i,:));
                    hold on
                end
            end
        end
        
end