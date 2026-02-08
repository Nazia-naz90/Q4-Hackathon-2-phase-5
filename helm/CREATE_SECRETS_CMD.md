# Create Kubernetes Secrets Manually

Run this command once to create the secrets directly in your cluster:

```bash
kubectl create secret generic todo-app-secrets \
  --from-literal=DATABASE_URL="your_actual_database_url_here" \
  --from-literal=OPENAI_API_KEY="your_actual_openai_api_key_here" \
  --from-literal=SECRET_KEY="your_actual_secret_key_here" \
  --from-literal=POSTGRES_USER="your_actual_postgres_user_here" \
  --from-literal=POSTGRES_PASSWORD="your_actual_postgres_password_here" \
  --from-literal=POSTGRES_DB="your_actual_postgres_db_here"
```

Replace the placeholder values with your actual credentials. This creates the secret directly in the cluster without storing them in any files.