# Clean up sensitive files from the project

# Remove .env file containing real credentials
rm -f .env

# Remove secrets-values.yaml file containing real credentials
rm -f todo-app/secrets-values.yaml

# Verify cleanup
echo "Checking for sensitive files..."
if [ -f ".env" ]; then
    echo "WARNING: .env file still exists!"
else
    echo "✓ .env file removed"
fi

if [ -f "todo-app/secrets-values.yaml" ]; then
    echo "WARNING: secrets-values.yaml file still exists!"
else
    echo "✓ secrets-values.yaml file removed"
fi

echo "Cleanup complete. Remember to create your secrets directly in Kubernetes."