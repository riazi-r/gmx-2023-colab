wget https://ftp.gromacs.org/gromacs/gromacs-2024.tar.gz
tar xfz gromacs-2024.tar.gz &&
cd gromacs-2024
mkdir build
cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_INSTALL_PREFIX=/usr/local/gromacs2024 -DCMAKE_BUILD_TYPE=Debug -DGMX_GPU=CUDA -DGMXAPI=ON &&
make -j 8 && 
make check &&
sudo make install &&
source /usr/local/gromacs2024/bin/GMXRC

#-DGMX_CUDA_TARGET_SM=90
#-DBUILD_SHARED_LIBS=ON
