# 🎲 Deployment Roulette

![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)
![EKS](https://img.shields.io/badge/EKS-%23232F3E.svg?style=for-the-badge&logo=amazonaws&logoColor=white)
![Jira](https://img.shields.io/badge/Jira-0052CC?style=for-the-badge&logo=jira&logoColor=white)

> 🧠 This project was originally created as part of the [Site Reliability Engineer Nanodegree](https://www.udacity.com/course/site-reliability-engineer-nanodegree--nd1331) by Udacity.

## 📖 Overview

**Deployment Roulette** is an experimental project that explores automated deployment strategies and CI/CD integrations using GitHub Actions. It demonstrates:

- 🟢 **Canary deployments** to AWS EKS clusters
- 📝 **JIRA automation**: auto-creating tickets from pull requests

This project uses GitHub Actions to orchestrate selective deployments and cross-platform issue management as part of a modern SRE workflow.

> ⚠️ **Note**: This project focuses on automation workflows and integration logic. Some shell scripts or services may be mocked or intentionally left abstract.

---

## 📦 Dependencies

To run or test these workflows locally, you should have:

- [AWS CLI](https://aws.amazon.com/cli/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [eksctl](https://eksctl.io/introduction/#installation)
- [terraform](https://developer.hashicorp.com/terraform/downloads)
- [helm](https://helm.sh/docs/intro/install/)

---

## 🗂️ Project Structure

- `.github/workflows/canary-deployment.yml`: triggers canary deploys to EKS
- `.github/workflows/manual.yml`: auto-creates JIRA tickets from PRs

---

## 🚀 How It Works

### 🔁 `canary-deployment.yml`

Triggered by:
- Opening or reopening a Pull Request
- Manual invocation from the GitHub Actions tab

Performs:
1. Configures AWS credentials using GitHub OIDC
2. Connects to an EKS cluster
3. Runs a `canary.sh` deployment script (must be defined in `/starter/apps/canary/`)

Use Case: Progressive delivery strategy — a new version is deployed to a subset of pods/users before full rollout.

---

### 🔧 `manual.yml`

Triggered by:
- Opening or reopening a Pull Request
- Manual trigger from Actions tab

Performs:
1. Authenticates to JIRA via secrets
2. Creates a new issue in the `CONUPDATE` project
3. Assigns type `Task` and links PR info into the summary

Use Case: Streamlining workflow between GitHub and JIRA during feature/bug deployments.

---

## 🔐 Secrets Required

Set the following GitHub Actions secrets for workflows to succeed:

### AWS for Canary Deployments:
- `AWS_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN` (if using temporary creds)

### JIRA for Issue Creation:
- `JIRA_BASE_URL`
- `JIRA_USER_EMAIL`
- `JIRA_API_TOKEN`

---

## 🙌 Author

Made with ❤️ and 🧉 by [Cristian Cevasco](https://github.com/circobit)
