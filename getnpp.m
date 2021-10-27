
function [npp, date, lat, lon] = getnpp(OPTN)

% Read npp product hdf files from Oregon State Ocean Productivity. 
%
% INPUT: OPTN is either a single hdf filename, or a filedirectory contianing
% multiple hdf files. 
% OUTPUT: npp is a 1080 x 2160 x n dimension matrix of npp values (mg m^-3
% d^-1), where n = # files read, which = number of time observations
% date = n x 2 array. column 1 holds the year and column 2 holds the month
% for the data. 
% lat = 1080 array. lat degrees from -90 to 90 for each grid cell
% lon = 2160 array. lon degrees from -180 t0 180 for each grid cell. s
%
% Yayla Sezginer. Oct 26, 2021

%===========================================================================

TF = contains(OPTN, '.hdf');

% Determine whether to read single hdf file or a folder
if TF == 1
    fn = {OPTN};
else
    files = dir(OPTN);
    realfiles = contains({files.name}, '.hdf');
    files = files(realfiles);
    
    for i = 1:sum(realfiles)
        fn{i} = [OPTN '/' files(i).name];
    end
    
end

% determine dimensions of data matrix
LAT = 1080;
LON = 2160;
n = sum(realfiles);

%initialize dataset matrix
npp = ones(LAT,LON,n);
date = ones(n,2); %[yr, month]

%read data into matrix
for i = 1:n

filename = fn{i};    
hinfo = hdfinfo(filename);
data = hdfread(hinfo.Filename, hinfo.SDS.Name);
npp(:,:,i) = npp(:,:,i).*data;

%parse filename for date

fstring = split(string(filename),'.');
dstring = char(fstring(2)); %dstring = yyyyddd, ddd = day of year
yr = str2double(dstring(1:4));
dvec = datevec(datenum(yr,1,str2double(dstring(5:7))));
month = dvec(2);
date(i,:) = [yr, month];

end

latgrid = 1:LAT;
longrid = 1:LON;

lat = 90 - 1/6*(latgrid-1) -1/12*(latgrid - 1);
%          ^shift latitude by grid size ^center grid
lon = -180 + 1/6*(longrid-1) + 1/12*(longrid - 1);

end
