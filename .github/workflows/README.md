# GitHub Actions Deployment to GKE

This workflow builds Docker images for all three services (application-service, order-service, patient-service) and deploys them to your GKE cluster.

## Prerequisites

1. **GCP Project**: `flash-spot-478811-m2`
2. **GKE Cluster**: `autopilot-cluster-1` in region `us-central1`
3. **Artifact Registry**: Repository `hclhackathonshiva` in `asia-docker.pkg.dev`

## Setup Instructions

### Option 1: Service Account Key (Easier Setup)

1. Create a Service Account in GCP:
   ```bash
   gcloud iam service-accounts create github-actions-sa \
     --display-name="GitHub Actions Service Account" \
     --project=flash-spot-478811-m2
   ```

2. Grant necessary permissions:
   ```bash
   # Grant Artifact Registry permissions
   gcloud projects add-iam-policy-binding flash-spot-478811-m2 \
     --member="serviceAccount:github-actions-sa@flash-spot-478811-m2.iam.gserviceaccount.com" \
     --role="roles/artifactregistry.writer"

   # Grant GKE permissions
   gcloud projects add-iam-policy-binding flash-spot-478811-m2 \
     --member="serviceAccount:github-actions-sa@flash-spot-478811-m2.iam.gserviceaccount.com" \
     --role="roles/container.developer"

   # Grant Cloud Build permissions (for pulling images)
   gcloud projects add-iam-policy-binding flash-spot-478811-m2 \
     --member="serviceAccount:github-actions-sa@flash-spot-478811-m2.iam.gserviceaccount.com" \
     --role="roles/storage.admin"
   ```

3. Create and download the JSON key:
   ```bash
   gcloud iam service-accounts keys create key.json \
     --iam-account=github-actions-sa@flash-spot-478811-m2.iam.gserviceaccount.com \
     --project=flash-spot-478811-m2
   ```

4. Add the secret to GitHub:
   - Go to your GitHub repository
   - Navigate to Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `GCP_SA_KEY`
   - Value: Contents of the `key.json` file (copy the entire JSON)

5. Update the workflow file:
   - The workflow already defaults to using `GCP_SA_KEY`
   - Make sure the credentials_json line is uncommented in `.github/workflows/deploy-gke.yml`

### Option 2: Workload Identity Federation (More Secure)

1. Create Workload Identity Pool and Provider (see [GCP documentation](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines))

2. Add these secrets to GitHub:
   - `WIF_PROVIDER`: Your Workload Identity Provider resource name
   - `WIF_SERVICE_ACCOUNT`: Service account email

3. Update the workflow file:
   - Uncomment the `workload_identity_provider` and `service_account` lines
   - Comment out the `credentials_json` line

## Artifact Registry Setup

Ensure your Artifact Registry repository exists:

```bash
gcloud artifacts repositories create hclhackathonshiva \
  --repository-format=docker \
  --location=asia \
  --project=flash-spot-478811-m2
```

## Workflow Triggers

The workflow runs automatically:
- On push to `main` branch
- Manually via GitHub Actions UI (workflow_dispatch)

## What the Workflow Does

1. **Builds Docker images** for all three services
2. **Pushes images** to GCP Artifact Registry with tags:
   - `${{ github.sha }}` (commit SHA)
   - `latest`
3. **Authenticates with GKE** using the provided credentials
4. **Creates/updates image pull secrets** in the cluster
5. **Deploys all three services** using kubectl
6. **Verifies deployments** are running

## Troubleshooting

- **Image pull errors**: Ensure the image pull secrets (`regcreds` and `servicesecret`) are created in the cluster
- **Authentication errors**: Verify your GCP service account has the correct permissions
- **Deployment failures**: Check logs with `kubectl logs deployment/<service-name>`

