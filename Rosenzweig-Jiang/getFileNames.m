% Source: StackOverflow (http://stackoverflow.com/questions/2652630/how-to-get-all-files-under-a-specific-directory-in-matlab)
% Licensed under cc by-sa 3.0 with attribution required (https://creativecommons.org/licenses/by-sa/3.0/#)
% Posted by: oz-radiano(http://stackoverflow.com/users/69555/oz-radiano)
% Modifications by Sebastian Rosenzweig: Renamed function from getAllFiles to getFileNames

function fileList = getFileNames(dirName, fileExtension, appendFullPath)

  dirData = dir([dirName '/' fileExtension]);      %# Get the data for the current directory
  dirWithSubFolders = dir(dirName);
  dirIndex = [dirWithSubFolders.isdir];  %# Find the index for directories
  fileList = {dirData.name}';  %'# Get a list of the files
  if ~isempty(fileList)
    if appendFullPath
      fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
    end
  end
  subDirs = {dirWithSubFolders(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getFileNames(nextDir, fileExtension, appendFullPath)];  %# Recursively call getAllFiles
  end

end