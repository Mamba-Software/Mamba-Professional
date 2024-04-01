#!/bin/bash

echo "Starting local testing script..."

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

echo "Preparing the deployment directory in firebase/build for local testing..."
# Ensure the build directory exists and is empty
mkdir -p firebase/build
rm -rf firebase/build/web
# Copy the build artifacts from the project's build/web to firebase/build/web
cp -r build/web firebase/build/

echo "Deployment directory for local testing ready."

# Change to the firebase directory to run firebase serve
cd firebase

echo "Starting Firebase Hosting locally with firebase serve..."
echo "Manually kill this script to stop the hosting..."

firebase serve --only hosting
