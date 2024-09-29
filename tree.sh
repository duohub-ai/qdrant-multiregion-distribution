#!/bin/bash

# Function to get ignored patterns from .gitignore
get_ignore_patterns() {
    if [ -f .gitignore ]; then
        grep -v '^#' .gitignore | grep -v '^\s*$' | sed 's/^/-I /' | tr '\n' ' '
    fi
}

# Get ignore patterns
IGNORE_PATTERNS=$(get_ignore_patterns)

# Run tree command with ignore patterns
tree -a $IGNORE_PATTERNS --prune -I '.git'