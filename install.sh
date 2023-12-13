tar xfz gromacs-2022.tar.gz &&
cd gromacs-2022
mkdir build
cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_INSTALL_PREFIX=/usr/local/gromacs2022 -DCMAKE_BUILD_TYPE=Debug -DGMX_GPU=CUDA -DGMXAPI=ON &&
make -j 10 && 
make check &&
sudo make install &&
source /usr/local/gromacs2022/bin/GMXRC