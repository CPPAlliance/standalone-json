
@ECHO ON
setlocal enabledelayedexpansion

set TRAVIS_OS_NAME=windows

IF "!DRONE_BRANCH!" == "" (
  for /F %%i in ("!GITHUB_REF!") do @set TRAVIS_BRANCH=%%~nxi
) else (
  SET TRAVIS_BRANCH=!DRONE_BRANCH!
)

if "%DRONE_JOB_BUILDTYPE%" == "boost" (

echo "Running boost job"
echo '==================================> INSTALL'
REM there seems to be some problem with b2 bootstrap on Windows
REM when CXX env variable is set
SET "CXX="

git clone https://github.com/boostorg/boost-ci.git boost-ci-cloned --depth 1
cp -prf boost-ci-cloned/ci .
rm -rf boost-ci-cloned
REM source ci/travis/install.sh
REM The contents of install.sh below:

for /F %%i in ("%DRONE_REPO%") do @set SELF=%%~nxi
SET BOOST_CI_TARGET_BRANCH=!TRAVIS_BRANCH!
SET BOOST_CI_SRC_FOLDER=%cd%

call ci\common_install.bat

echo '==================================> COMPILE'

set B2_TARGETS=libs/!SELF!/test libs/!SELF!/example
call !BOOST_ROOT!\libs\!SELF!\ci\build.bat

) else if "%DRONE_JOB_BUILDTYPE%" == "standalone-windows" (

echo '==================================> INSTALL'

REM Installing cmake with choco in the Dockerfile, so not required here:
REM choco install cmake

echo '==================================> COMPILE'

set CXXFLAGS="/std:c++17"
mkdir __build_17
cd __build_17
cmake -DBOOST_JSON_STANDALONE=1 ..
cmake --build .
ctest -V -C Debug .
set CXXFLAGS="/std:c++latest"
mkdir ..\__build_2a
cd ..\__build_2a
cmake -DBOOST_JSON_STANDALONE=1 ..
cmake --build .
ctest -V -C Debug .
)
