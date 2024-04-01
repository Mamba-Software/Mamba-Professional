#!/bin/bash

echo "Starting deployment script..."

# Ensure script is executed from the firebase/hosting directory
if [[ $PWD != *"firebase/hosting"* ]]; then
  echo "This script should be run from the firebase/hosting directory."
  exit 1
fi

# Navigate to the project root directory from firebase/hosting
cd ../..

echo "Checking for existing firebase/build/web directory..."
if [ -d "firebase/build/web" ]; then
    echo "Existing firebase/build/web directory found. Cleaning up..."
    rm -rf firebase/build/web
fi

echo "Preparing the deployment directory in firebase/build for deployment..."
mkdir -p firebase/build
rm -rf firebase/build/web
cp -r build/web firebase/build/

echo "Deployment directory for deployment ready."

# Change to the firebase directory to run firebase deploy
cd firebase

echo "Deploying to Firebase Hosting..."
if firebase deploy --only hosting; then
  echo "Deployment completed successfully."
  
  # Cleanup after successful deployment
  echo "Cleaning up the firebase directory and .firebase cache..."
  rm -rf build
  rm -rf .firebase
  
else
  echo "Deployment encountered an issue. Check the logs above for details."
  exit 1
fi

# Display the list of all deployed versions
echo "Listing all deployed versions..."
firebase hosting:sites:list

# Display the list of all channels and their URLs
echo "Listing all channels..."
firebase hosting:channel:list

echo "Deployment script finished."

echo "Press enter to close..."
read
