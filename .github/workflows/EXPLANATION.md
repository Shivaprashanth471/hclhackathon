# GitHub Actions Workflow - Line by Line Explanation

## Header Section (Lines 1-11)

```yaml
name: Build and Push Docker Images
```
**Line 1:** Sets the display name of this workflow. This appears in the GitHub Actions tab.

```yaml

```
**Line 2:** Empty line for readability.

```yaml
on:
```
**Line 3:** Defines when this workflow should trigger. This is the trigger section.

```yaml
  push:
```
**Line 4:** Triggers the workflow when code is pushed to the repository.

```yaml
    branches:
```
**Line 5:** Specifies which branches should trigger the workflow.

```yaml
      - main
```
**Line 6:** Triggers on pushes to the `main` branch.

```yaml
      - master
```
**Line 7:** Triggers on pushes to the `master` branch (for older repos).

```yaml

```
**Line 8:** Empty line.

```yaml
env:
```
**Line 9:** Defines environment variables available to all jobs in this workflow.

```yaml
  DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
```
**Line 10:** Creates an environment variable `DOCKERHUB_USERNAME` that gets its value from GitHub Secrets. The `${{ }}` syntax is GitHub Actions expression syntax.

---

## Jobs Section - Change Detection (Lines 12-33)

```yaml
jobs:
```
**Line 12:** Defines the jobs (tasks) that will run in this workflow.

```yaml
  check-changes:
```
**Line 13:** First job named `check-changes`. This job detects which service folders have changes.

```yaml
    runs-on: ubuntu-latest
```
**Line 14:** Runs this job on the latest Ubuntu virtual machine. GitHub provides free runners.

```yaml
    outputs:
```
**Line 15:** Defines outputs from this job that can be used by other jobs.

```yaml
      patient: ${{ steps.filter.outputs.patient }}
```
**Line 16:** Creates output `patient` that will be `'true'` if patient-service folder changed, `'false'` otherwise. Gets value from the `filter` step.

```yaml
      application: ${{ steps.filter.outputs.application }}
```
**Line 17:** Creates output `application` that will be `'true'` if application-service folder changed.

```yaml
      order: ${{ steps.filter.outputs.order }}
```
**Line 18:** Creates output `order` that will be `'true'` if order-service folder changed.

```yaml
    steps:
```
**Line 19:** Defines the steps (actions) to execute in this job.

```yaml
      - name: Checkout code
```
**Line 20:** Step name that will appear in the GitHub Actions log.

```yaml
        uses: actions/checkout@v4
```
**Line 21:** Uses the official GitHub checkout action to download the repository code to the runner.

```yaml
      
```
**Line 22:** Empty line.

```yaml
      - name: Check for changes
```
**Line 23:** Step name for checking which paths changed.

```yaml
        uses: dorny/paths-filter@v2
```
**Line 24:** Uses a third-party action that detects file path changes between commits.

```yaml
        id: filter
```
**Line 25:** Gives this step an ID so we can reference its outputs later (like `steps.filter.outputs.patient`).

```yaml
        with:
```
**Line 26:** Provides input parameters to the action.

```yaml
          filters: |
```
**Line 27:** Defines the path filters. The `|` means multi-line YAML string.

```yaml
            patient:
```
**Line 28:** Defines a filter named `patient`.

```yaml
              - 'patient-service/**'
```
**Line 29:** If any file in `patient-service/` or its subdirectories (`**` means recursive) changed, the `patient` filter will be `true`.

```yaml
            application:
```
**Line 30:** Defines a filter named `application`.

```yaml
              - 'application-service/**'
```
**Line 31:** If any file in `application-service/` changed, the `application` filter will be `true`.

```yaml
            order:
```
**Line 32:** Defines a filter named `order`.

```yaml
              - 'order-service/**'
```
**Line 33:** If any file in `order-service/` changed, the `order` filter will be `true`.

---

## Build Patient Service Job (Lines 35-59)

```yaml
  build-patient:
```
**Line 35:** Second job named `build-patient`. This builds the patient-service Docker image.

```yaml
    needs: check-changes
```
**Line 36:** This job depends on `check-changes` job completing first. Jobs run in parallel by default, but `needs` creates a dependency.

```yaml
    if: needs.check-changes.outputs.patient == 'true'
```
**Line 37:** Conditional execution. This job ONLY runs if the `patient` output from `check-changes` job equals `'true'`. If no changes in patient-service, this job is skipped.

```yaml
    runs-on: ubuntu-latest
```
**Line 38:** Runs on Ubuntu latest (same as before).

```yaml
    steps:
```
**Line 39:** Defines steps for this job.

```yaml
      - name: Checkout code
```
**Line 40:** Step name.

```yaml
        uses: actions/checkout@v4
```
**Line 41:** Downloads the repository code again (each job runs in a fresh VM).

```yaml

```
**Line 42:** Empty line.

```yaml
      - name: Set up Docker Buildx
```
**Line 43:** Step name for setting up Docker Buildx.

```yaml
        uses: docker/setup-buildx-action@v3
```
**Line 44:** Installs Docker Buildx, an extended Docker CLI with advanced build features (caching, multi-platform, etc.).

```yaml

```
**Line 45:** Empty line.

```yaml
      - name: Login to Docker Hub
```
**Line 46:** Step name for Docker Hub authentication.

```yaml
        uses: docker/login-action@v3
```
**Line 47:** Official Docker action to log in to Docker Hub.

```yaml
        with:
```
**Line 48:** Provides parameters to the login action.

```yaml
          username: ${{ secrets.DOCKERHUB_USERNAME }}
```
**Line 49:** Docker Hub username from GitHub Secrets (secure storage).

```yaml
          password: ${{ secrets.DOCKERHUB_TOKEN }}
```
**Line 50:** Docker Hub access token from GitHub Secrets (NOT your password, but a token).

```yaml

```
**Line 51:** Empty line.

```yaml
      - name: Build and push patient-service
```
**Line 52:** Step name for building and pushing the Docker image.

```yaml
        uses: docker/build-push-action@v5
```
**Line 53:** Official Docker action that builds and pushes images in one step.

```yaml
        with:
```
**Line 54:** Parameters for the build-push action.

```yaml
          context: ./patient-service
```
**Line 55:** Build context - the directory containing the Dockerfile and source files.

```yaml
          push: true
```
**Line 56:** Actually push the image to Docker Hub (set to `false` to only build locally).

```yaml
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/patient-service:latest
```
**Line 57:** The full image name and tag. Example: `myusername/patient-service:latest`

```yaml
          cache-from: type=gha
```
**Line 58:** Use GitHub Actions cache to speed up builds by reusing previous build layers.

```yaml
          cache-to: type=gha,mode=max
```
**Line 59:** Save build cache to GitHub Actions cache with maximum caching (`max` mode caches all layers).

---

## Build Application Service Job (Lines 61-85)

```yaml
  build-application:
```
**Line 61:** Third job for building application-service. Same structure as `build-patient`.

```yaml
    needs: check-changes
```
**Line 62:** Depends on `check-changes` job.

```yaml
    if: needs.check-changes.outputs.application == 'true'
```
**Line 63:** Only runs if `application-service` folder has changes.

```yaml
    runs-on: ubuntu-latest
```
**Line 64:** Runs on Ubuntu.

```yaml
    steps:
```
**Line 65:** Job steps.

```yaml
      - name: Checkout code
        uses: actions/checkout@v4
```
**Lines 66-67:** Checkout repository code.

```yaml

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
```
**Lines 69-70:** Setup Docker Buildx.

```yaml

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
```
**Lines 72-76:** Login to Docker Hub with credentials.

```yaml

      - name: Build and push application-service
        uses: docker/build-push-action@v5
        with:
          context: ./application-service
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/application-service:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```
**Lines 78-85:** Build and push application-service image. Same as patient-service but different context and tag.

---

## Build Order Service Job (Lines 87-111)

```yaml
  build-order:
```
**Line 87:** Fourth job for building order-service.

```yaml
    needs: check-changes
```
**Line 88:** Depends on `check-changes` job.

```yaml
    if: needs.check-changes.outputs.order == 'true'
```
**Line 89:** Only runs if `order-service` folder has changes.

```yaml
    runs-on: ubuntu-latest
```
**Line 90:** Runs on Ubuntu.

```yaml
    steps:
```
**Line 91:** Job steps.

```yaml
      - name: Checkout code
        uses: actions/checkout@v4
```
**Lines 92-93:** Checkout repository code.

```yaml

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
```
**Lines 95-96:** Setup Docker Buildx.

```yaml

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
```
**Lines 98-102:** Login to Docker Hub.

```yaml

      - name: Build and push order-service
        uses: docker/build-push-action@v5
        with:
          context: ./order-service
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/order-service:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```
**Lines 104-111:** Build and push order-service image.

---

## Summary

**Workflow Flow:**
1. **Trigger:** Push to `main` or `master` branch
2. **Check Changes:** Detects which service folders changed
3. **Build Jobs:** Only build services that have changes
4. **Push:** Push built images to Docker Hub

**Key Concepts:**
- `needs:` - Job dependencies (runs in sequence)
- `if:` - Conditional execution (skip if condition false)
- `outputs:` - Pass data between jobs
- `secrets:` - Secure storage for sensitive data
- `cache:` - Speed up builds by reusing layers

