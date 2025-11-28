#!/bin/bash

echo "Running tests with coverage..."
fvm flutter test --coverage

echo "Generating HTML report..."
genhtml coverage/lcov.info -o coverage/html

echo "Opening coverage report..."
open coverage/html/index.html