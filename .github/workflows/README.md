# GitHub Actions Workflows

## Docker Build and Push

This workflow automatically builds and pushes Docker images **only when there are changes** in the respective service folders.

### Setup Instructions

1. **Create Docker Hub Access Token:**
   - Go to Docker Hub → Account Settings → Security
   - Click "New Access Token"
   - Give it a name (e.g., "github-actions")
   - Copy the token (you won't see it again!)

2. **Add GitHub Secrets:**
   - Go to your GitHub repository → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Add the following secrets:
     - `DOCKERHUB_USERNAME`: Your Docker Hub username
     - `DOCKERHUB_TOKEN`: The access token you created

### How It Works

The workflow checks which service folders have changes:
- **patient-service/** → Builds `patient-service:latest`
- **application-service/** → Builds `application-service:latest`
- **order-service/** → Builds `order-service:latest`

**Only services with changes will be built and pushed!**

### Example Scenarios

- ✅ You change `patient-service/src/index.js` → Only `patient-service` image is built
- ✅ You change `order-service/pom.xml` → Only `order-service` image is built
- ✅ You change `README.md` → No images are built (no service changes)
- ✅ You change files in multiple services → All changed services are built

### Image Names

Images will be pushed as:
- `YOUR_DOCKERHUB_USERNAME/patient-service:latest`
- `YOUR_DOCKERHUB_USERNAME/application-service:latest`
- `YOUR_DOCKERHUB_USERNAME/order-service:latest`

### Pulling Images

After the workflow runs, you can pull images:
```bash
docker pull YOUR_DOCKERHUB_USERNAME/patient-service:latest
docker pull YOUR_DOCKERHUB_USERNAME/application-service:latest
docker pull YOUR_DOCKERHUB_USERNAME/order-service:latest
```

