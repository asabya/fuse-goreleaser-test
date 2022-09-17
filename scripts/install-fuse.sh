#!/bin/sh

case "$(uname -s)" in

  Darwin)
    echo 'Mac OS X'
    brew install macfuse
    git clone -q https://github.com/billziss-gh/secfs.test.git secfs.test
    git -C secfs.test checkout -q edf5eb4a108bfb41073f765aef0cdd32bb3ee1ed
    mkdir -p secfs.test/tools/bin
    touch secfs.test/tools/bin/bonnie++
    touch secfs.test/tools/bin/iozone
    make -C secfs.test
    # configure fstest for cgofuse
    sed -e 's/^fs=.*$/fs="cgofuse"/' -i ""  secfs.test/fstest/fstest/tests/conf
    # monkey-patch/disable some tests for macOS
    rm secfs.test/fstest/fstest/tests/rmdir/12.t
    sed -e 's/lchmod)/lchmod) return 1/' -i "" secfs.test/fstest/fstest/tests/misc.sh
    # remove irrelevant tests
    rm -rf secfs.test/fstest/fstest/tests/xacl
    rm -rf secfs.test/fstest/fstest/tests/zzz_ResourceFork
    ;;

  Linux)
    echo 'Linux'
    sudo apt-get -qq install libfuse-dev
    sudo apt-get -qq install libacl1-dev
    git clone -q https://github.com/billziss-gh/secfs.test.git secfs.test
    git -C secfs.test checkout -q edf5eb4a108bfb41073f765aef0cdd32bb3ee1ed
    mkdir -p secfs.test/tools/bin
    touch secfs.test/tools/bin/bonnie++
    touch secfs.test/tools/bin/iozone
    make -C secfs.test
    # configure fstest for cgofuse
    sed -e 's/^fs=.*$/fs="cgofuse"/' -i""  secfs.test/fstest/fstest/tests/conf
    # remove irrelevant tests
    rm -rf secfs.test/fstest/fstest/tests/xacl
    rm -rf secfs.test/fstest/fstest/tests/zzz_ResourceFork
    ;;

  CYGWIN*|MINGW32*|MSYS*|MINGW*)
    echo 'MS Windows'
    # shellcheck disable=SC1066
    $releases=Invoke-WebRequest https://api.github.com/repos/winfsp/winfsp/releases | ConvertFrom-Json
    # shellcheck disable=SC1066
    # shellcheck disable=SC1087
    # shellcheck disable=SC2125
    # shellcheck disable=SC2036
    # shellcheck disable=SC2154
    # shellcheck disable=SC1083
    # shellcheck disable=SC2039
    $asseturi=$releases[0].assets.browser_download_url | Where-Object { $_ -match "winfsp-.*\.msi" }
    Invoke-WebRequest -Uri $asseturi -Out winfsp.msi
    Start-Process -NoNewWindow -Wait msiexec "/i winfsp.msi /qn INSTALLLEVEL=1000"
    # shellcheck disable=SC1066
    # shellcheck disable=SC1087
    # shellcheck disable=SC2036
    # shellcheck disable=SC2125
    # shellcheck disable=SC1083
    # shellcheck disable=SC2039
    $asseturi=$releases[0].assets.browser_download_url | Where-Object { $_ -match "winfsp-tests-.*\.zip" }
    Invoke-WebRequest -Uri $asseturi -Out winfsp-tests.zip
    Expand-Archive -Path winfsp-tests.zip
    Copy-Item "C:\Program Files (x86)\WinFsp\bin\winfsp-x64.dll" winfsp-tests
    ;;

    # Add here more strings to compare
    # See correspondence table at the bottom of this answer

  *)
    echo 'Other OS'
    ;;
esac