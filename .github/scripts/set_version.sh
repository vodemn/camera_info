export newVersion="$1"

if [[ -n "$newVersion" ]]; then
    # https://stackoverflow.com/a/30214769/13167574
    perl -i -pe 's/^(version:\s+)\d+\.\d+\.\d+$/${1}$ENV{"newVersion"}/' pubspec.yaml
    perl -i -pe "s/(s\\.version\\s*=\\s*')[^']*'/\${1}\$ENV{\"newVersion\"}'/" ios/camera_info.podspec
    perl -i -pe 's/(camera_info:\s+\^)\d+\.\d+\.\d+/${1}$ENV{"newVersion"}/' README.md
else
    echo "argument error"
fi
