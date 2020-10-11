# Kubernetes Manifests Files to Create AWS ECR Credentials Updater Cron

1. Modify included files to suit or accept defaults

2. Create role
   ```
   kubectl apply -f aws-ecr-credentials-updater-role.yaml -n aws-ecr-credentials-updater
   ```

3. Modify `aws-ecr-credentials-updater-secrets.yaml`, apply to create secrets
   ```
   kubectl apply -f ./aws-ecr-credentials-updater-secrets.yaml -n aws-ecr-credentials-updater 
   ```

4. Create cron
   ```
   kubectl apply -f aws-ecr-credentials-updater-cron.yaml -n aws-ecr-credentials-updater 
   
   ```
