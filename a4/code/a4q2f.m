%%Assignment 4 Q2f
% Descriptive output:
% Sequence order:
% Cars > Bikes > Persons 
% or by object distance regardless of type

L1 = load('L1.mat');
L2 = load('L2.mat');
L3 = load('L3.mat');

R1 = load('R1.mat');
R2 = load('R2.mat');
R3 = load('R3.mat');

[L1a,L1b] = getDescription(L1);
[L2a,L2b] = getDescription(L2);
[L3a,L3b] = getDescription(L3);

[R1a,R1b] = getDescription(R1);
[R2a,R2b] = getDescription(R2);
[R3a,R3b] = getDescription(R3);

function [desc,desc2]=getDescription(scene)
    desc = string('');
    
    cars = scene.resCar;
    people = scene.resPerson;
    bikes = scene.resBike;
    
    %thresholding out probable false detections
    cThresh = -0.5;
    pThresh = -0.48;
    bThresh = -0.95;%-0.5;
    cars = cars(cars(:,6)>cThresh,:);
    people = people(people(:,6)>=pThresh,:);
    bikes = bikes(bikes(:,6)>=bThresh,:);
    
    centerLine = size(scene.img,2)/2;
    
    %% Form the description of the scene - by ordered by object type
    numCars = size(cars,1);
    numPeople = size(people,1);
    numBikes = size(bikes,1);
    desc = desc + sprintf('There are %d cars, %d persons, and %d bikes ahead\n',numCars, numPeople, numBikes);
    desc2 = desc;
    
    byDist = [];
    for i=1:numCars
        dist = round(scene.cmCar(i,3)); %depth for this object
        objX = scene.cmCar(i,1); %x position of this object
        if objX > centerLine
            direction = 'right';
        else
            direction = 'left';
        end
        desc = desc + sprintf('Car %d is %d m away to your %s\n',i,dist,direction);
        byDist = cat(1,byDist,[1,dist,objX]);
    end
    
    for i=1:numPeople
        dist = round(scene.cmPerson(i,3)); %depth for this object
        objX = scene.cmPerson(i,1); %x position of this object
        if objX > centerLine
            direction = 'right';
        else
            direction = 'left';
        end
        desc = desc + sprintf('Person %d is %d m away to your %s\n',i,dist,direction);
        byDist = cat(1,byDist,[2,dist,objX]);
    end
    
    for i=1:numBikes
        dist = round(scene.cmBike(i,3)); %depth for this object
        objX = scene.cmBike(i,1); %x position of this object
        if objX > centerLine
            direction = 'right';
        else
            direction = 'left';
        end
        desc = desc + sprintf('Bike %d is %d m away to your %s\n',i,dist,direction);
        byDist = cat(1,byDist,[3,dist,objX]);
    end
    
    %% Second description type, ordered by distance instead of type
    byDist = sortrows(byDist,2);
    for i=1:size(byDist,1)
        if byDist(i,1) == 1
            type = 'Car';
        elseif byDist(i,1) == 2
            type = 'Person';
        else
            type = 'Bike';
        end
        
        if byDist(i,3) > centerLine
            direction = 'right';
        else
            direction = 'left';
        end
        
        desc2 = desc2 + sprintf('There is a %s %d m to your %s\n', type, byDist(i,2), direction);
    end  
end




