if [ $? -eq 0 ]; then
    echo -e "\nSuccessfully :)"
    sleep 2
else
    echo -e "\nUnsuccessfully :(\nStopping..."
    exit 1
fi
