%
% Use these variables to enable/disable different parts of the script.
%
loadImages           = false;  % also displays silhouettes
displayVolumeCorners = true;
computeVisualHull    = false;
displayVolumeSlices  = false;
displayIsoSurface    = false;

%
% Adjust these variables, one at a time, to get a good visual hull.
%

% Task 7.1 silhouette threshold
silhouetteThreshold = 120; 

% Task 7.2 define bounding box
bbox = [2.5 2 -2; 3.5 4 3]; % [minX minY minZ; maxX maxY maxZ];
volumeX = 10;
volumeY = 10;
volumeZ = 20;
volumeThreshold = 17;

home;
numCameras = 18;

if loadImages
    % Load silhouette images and projection matrices
    for n=1:numCameras
        Ps{n} = textread(sprintf('./data/david_%02d.pa',n-1));
        Ps{n} = [eye(3,2) [1 1 1]']*Ps{n};  % add 1 for one-based indices
        ims{n} = imread(sprintf('./data/david_%02d.jpg',n-1));
        sils{n} = rgb2gray(ims{n})>silhouetteThreshold;
        
        figure(1);
        subplot(1,2,1);
        imshow(sils{n});
        subplot(1,2,2);
        imshow(double(rgb2gray(ims{n}))/255.*sils{n});
        drawnow;
    end
end

% Define transformation from volume to world coordinates.
T = [eye(4,3) [bbox(1,:) 1]'] * ...
    diag([(bbox(2,1)-bbox(1,1))/volumeX ...
          (bbox(2,2)-bbox(1,2))/volumeY ...
          (bbox(2,3)-bbox(1,3))/volumeZ ...
          1]);
T = [1  0 0 0; ...
     0  0 1 0; ...  % flip y and z axes for better display in matlab figure (isosurface)
     0 -1 0 0; ...
     0  0 0 1] * T;
T = T*[eye(4,3) [-[1 1 1] 1]'];  % subtract 1 for one-based indices

if displayVolumeCorners
    % Draw projection of volume corners.
    for n=1:numCameras
        figure(2);
        hold off;
        imshow(ims{n});
        hold on;
        corners = [[      0       0       0 1]' ...
                   [      0       0 volumeZ 1]' ...
                   [      0 volumeY       0 1]' ...
                   [      0 volumeY volumeZ 1]' ...
                   [volumeX       0       0 1]' ...
                   [volumeX       0 volumeZ 1]' ...
                   [volumeX volumeY       0 1]' ...
                   [volumeX volumeY volumeZ 1]'];
        pcorners = Ps{n}*T*corners;
        pcorners = pcorners./repmat(pcorners(3,:),3,1);
        plot(pcorners(1,:),pcorners(2,:),'g*');
        drawnow;
        pause(0.1);
    end
end

if computeVisualHull
    % Define volume.
    volume = zeros(volumeX,volumeY,volumeZ);
    
    % Visual hull computation    
    % Task 7.3 Visual hull computation
    %   - add one to volume if projection is within silhouette region
    for i = 1:volumeX
        for j = 1:volumeY
            for k = 1:volumeZ
                p = [i-.5,j-.5,k-.5,1]';
                p_w = T * p;
                for n = 1:numCameras
                    p_img = Ps{n} * p_w;
                    p_img = p_img / p_img(3);
                    p_img = round(p_img);
                    if p_img(1) <= 0 || p_img(1) > size(sils{n}, 1)
                        continue;
                    end
                    if p_img(2) <= 0 || p_img(2) > size(sils{n}, 2)
                        continue;
                    end
                    
                    if sils{n}(p_img(1),p_img(2))
                        volume(i,j,k) = volume(i,j,k) + 1;
                    end
                end
            end
        end
    end
    
end

if displayVolumeSlices
    figure(3);
    hold off;
    for n=1:size(volume,3)
        imagesc(volume(:,:,n));
        drawnow;
        pause(0.1);
    end
end

if displayIsoSurface
    % display result
    figure(4);
    clf;
    grid on;
    xlabel('x');
    ylabel('y');
    zlabel('z');
    hold on;
    [xMesh yMesh zMesh] = meshgrid(1:volumeY,1:volumeX,1:volumeZ);
    pt = patch(isosurface(yMesh, xMesh, zMesh, volume, volumeThreshold));
    set(pt,'FaceColor','red','EdgeColor','none');
    axis equal;
    daspect([volumeX/(bbox(2,1)-bbox(1,1)) volumeY/(bbox(2,2)-bbox(1,2)) volumeZ/(bbox(2,3)-bbox(1,3))]);
    camlight(0,0);
    camlight(180,0);
    camlight(0,90);
    camlight(0,-90);
    lighting phong;
    view(30,30);
end


