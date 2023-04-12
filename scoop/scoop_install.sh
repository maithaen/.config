

if scoop --version &>/dev/null; then

    echo "Scoop install"
else
    echo "Scoop not install"
    exit 1
fi




for i in {1..10}; do
    echo "hi ${i}"
done