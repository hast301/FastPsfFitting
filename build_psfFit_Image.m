%  Build script for "psfFit_Image.m".
clear mex % so that we can overwrite the mexw64/mexa64 files

disp('Building psfFit_Image ..')

if ispc
% Note: compile with COMPFLAGS = "\D DEBUG ... " for debug output

% For static linking (no ceres.dll required, but big file, longer compilation time)
% mex LINKFLAGS="$LINKFLAGS /LIBPATH:ceres-windows\x64\Release libglog_static.lib ceres_static.lib " ...
%     COMPFLAGS="$COMPFLAGS /openmp ...
%     ... /D DEBUG ...
%     /D CERES_USING_STATIC_LIBRARY /D GOOGLE_GLOG_DLL_DECL= ...
%     /I ceres-windows\ceres-solver\include /I ceres-windows\win\include ...
%     /I ceres-windows\glog\src /I ceres-windows\glog\src\windows /I ceres-windows\eigen" ...
%     mx_psfFit_Image.cpp

% For dynamic linking 
mex LINKFLAGS="$LINKFLAGS /LIBPATH:ceres-windows\x64\Release ceres.lib libglog_static.lib" ...
    COMPFLAGS="$COMPFLAGS /openmp ...
    ... /D DEBUG ...
    /D GOOGLE_GLOG_DLL_DECL= ...
    /I ceres-windows\ceres-solver\include /I ceres-windows\win\include ...
    /I ceres-windows\glog\src /I ceres-windows\glog\src\windows /I ceres-windows\eigen" ...
    mx_psfFit_Image.cpp

copyfile('ceres-windows\x64\Release\ceres.dll','.')

elseif isunix
    % Matlab comes with its own c++ standard library, which is usually too
    % old and not compatible with shared libraries used by ceres.
    % As Matlab loads its own STL before the system libraries (by
    % setting LD_LIBRARY_PATH to the MATLAB library path) this will result
    % in failures when the mex file (shared library) is called.
    %
    % If you encounter invalid mex files while executing the program, or
    % runtime linking errors try setting the LD_PRELOAD environment variable 
    % before starting matlab to your system libraries (where libstdc++ and
    % libgfortran are located.
    mex -Lceres-windows/ceres-solver/build/lib/ -lceres -lpthread -lglog ...
    LDFLAGS='\$LDFLAGS -Wl,-rpath -Wl,''\\\$ORIGIN'' -fopenmp'  ...
    CXXFLAGS="\$CXXFLAGS -fopenmp -std=c++11 ...
    ... -D DEBUG ...
    -DGOOGLE_GLOG_DLL_DECL= ...
    -Iceres-windows/ceres-solver/include -Iceres-windows/ceres-solver/config ...
    -Iceres-windows/glog/src -Iceres-windows/eigen" ...
    mx_psfFit_Image.cpp
    
    % Copy ceres library files (including symbolic links) into this folder
    !cp ceres-windows/ceres-solver/build/lib/*.so* ./ 
end
    