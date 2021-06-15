# :pencil2: Exercises

The goal of these exercises is to create a CI/CT/CD workflow with GitHub Actions.

As you work progressively along all the ordered files, your workflow will become more complex and thorough.

### File Structures 🏗️

Before you go through these exercises, please be aware of the existing file contents and structures in this repository.

| File/Folder name | What it is for |
| ---------------- | -------------- |
| Exercises 📁 | Directory that you are looking at it! This folder contains the list of exercises you can go through to learn GitHub Actions |
| dependencies 📁 | This directory contains the files that can be enabled from **Dockerfile** 🐳 to install dependencies for different programming run time. You will create this Dockefile 🐳 from [Create Dockerfile](./01-Create-Dockerfile.md) |
| library  📁 | This directory contains a sample [**entrypoint.sh**](../library/entrypoint.sh) that is called from **Dockerfile** 🐳 to run the application. Feel free to explore and to modify |




### Steps 1: Create Continuous Integration (CI)

- [Create Dockerfile](./01-Create-Dockerfile.md)
- [Create CI Action](./02-Create-CI-Action.md)

### Steps 2: Adding more complexity to the CI

- These steps would be more informative if you adopt a Git Flow:
  - [Create QA Branch](./02.A-Create-QA-Branch.md)
  - [Create Context Job](./02.B-Create-Context-Job.md)

### Steps 3: Dependency Management

- [Create Dependabot Config](./03-Create-Dependabot-Config.md)
- [Lock Your Dependencies](./03.A-Lock-Dependencies.md)

### Step 4: Add Continuous Testing (CT)

- [Create CT Actions](./04-Create-CT-Actions.md)

### Step 5: Actions for Artifacts Management

- [Upload and Download Build Artifacts](./05-Upload-Download-Artifacts.md)

### Step 6: Create Continuous Deployment (CD)

- [Create CD Actions](./06-Create-CD-Actions.md)
- [Deploy Docker Image](./06.A-Deploy-Prod.md)
- [Deploy Release Images](./06.B-Deploy-Release.md)

### Optional: Using Actions beyond CI/CT/CD

- [Using Actions to Create Issues](./07.A-GitHub-Script-Actions.md)
- [Using GitHub's API for Deployment to Update Environments](./07.B-Add-Deployment-API.md)
- [**Advanced**: Wait for Steps to Require Other Jobs to Complete](./07.C-Add-Wait-For-Steps.md)
- [**Advanced**: Additional information on Best Practices for Complex Workflows](./07.D-Split-Jobs-for-Speed.md)
- [**Advanced**: Resuing a Local Action](./08-Create-New-Repo-To-Pull-In-Container.md)

## :book: Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/free-pro-team@latest/actions)
- [Self-paced Learning Lab Course on DevOps Pipeline with GitHub Actions](https://lab.github.com/githubtraining/devops-with-github-actions)
