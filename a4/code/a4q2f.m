%%Assignment 4 Q2f

% Create a textual description of the scene. 
% Convey more important facts before the less important ones. 
% Think what you, as a driver, would like to know first.
% Think of the camera centre as the driver.
% 
% In your description, generate at least a sentence about 
% how many cars, how many people and cyclists are in the scene. 
% 
% Generate also a sentence that tells the driver 
% which object is the closest to him and where it is.
% 
% For example, let’s say you have an object with location (X,Y,Z) 
% in 3D and label = car and you want to generate a sentence about where it is. 
% 
% You could do something like:
% d = norm([X, Y, Z]); % this is the distance of object to driver 
% if X ≥ 0, txt = “to your right”; 
% else txt = “to your left”; 
% end; 
% fprintf(“There is a %s %0.1f meters %s \n”, label, X, txt);
% fprintf(“It is %0.1 meters away from you \n”, d);


% Total object counts : Histogram

% Descriptive output:
% Sequence order:
% Cars > Bikes > Persons 

% For each object:
% Use center of mass for:
% Left/Right of Camera Center (viewpoint_xlim/2)
% Distance from Camera 

% How to remove false positives - should have done better NMS at start -
% adjusting for object type and being more strict about outliers
% Still, scores are inconsistent across objects
% Taking a look at the data use the following relaxations on detection
% score

% Car (Score > 0)
% Bike (Score >= -0.5)
% Person (Score >= -0.5)

% Camera center = size(img,2)/2




