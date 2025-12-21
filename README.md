# docker-terragrunt <img src="https://assets.jblab.info/2024/03/17/jblab-logo-with-text.26da23672fc44c17078dc8ce2ff8495ddb190163.webp" alt="jblab logo" width="120" align="right" style="max-width: 100%">

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square)](LICENSE) [![Latest Release](https://img.shields.io/github/release/jblab/docker-terragrunt.svg?style=flat-square)](https://github.com/jblab/docker-terragrunt/releases/latest) ![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/jblab/docker-terragrunt/main.yaml?style=flat-square)

This Docker image includes Terraform and Terragrunt, which are essential tools for managing infrastructure as code. It
can be used for local development to avoid managing different versions of these tools on your system or as part of your
CI/CD pipelines. The lightweight, Ubuntu-based image ensures that you run your pipelines in a consistent environment.

---

## How to Use

> [!IMPORTANT]
>
> We intentionally do not pin the container image to a specific version in our examples to avoid the challenge of
> keeping the documentation aligned with the latest releases. However, we strongly recommend that you always specify the
> exact version of the container image in your code. Doing so ensures your infrastructure remains stable and
> predictable. Additionally, make sure to update versions systematically to avoid unexpected issues.

> [!TIP]
>
> Three variants of the image are available on Docker Hub:
>
> 1. The base image: Also tagged as `latest`, this image contains only the essential tools required for Terragrunt and
>    Terraform.
> 2. The `dev-tools` image: Includes additional tools such as `vim`, `tree`, `make`, and `graphviz`, which are useful
>    during local development and when building Infrastructure-as-Code (IaC) projects.
> 3. The `azdo` image: Includes Node.js, a requirement for running Azure DevOps Pipeline container jobs with **Linux**
>    containers on **Windows** hosts. For more details, refer to [the official Azure documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops&tabs=linux#additional-container-requirements).
>
> Choose the variant that best suits your specific task.


Pull the Docker image from the Docker Hub:

```shell
docker pull jbonnier/terragrunt:latest
```

To run the `terraform` command:

```shell
docker run -it --rm jbonnier/terragrunt:latest terraform -version
```

To run the `terragrunt` command:

```shell
docker run -it --rm jbonnier/terragrunt:latest terragrunt -version
```

### Using the Image Locally

By using Docker, you can avoid managing multiple versions of Terraform and Terragrunt on your local system. All you need
is Docker, and you can run any encapsulated version of Terraform and Terragrunt inside the Docker image.

### Using the Image in CI/CD Pipelines

The Docker image is also beneficial in CI/CD pipelines, where it creates a consistent environment across different
pipeline stages. This consistency ensures that your infrastructure builds are reliable and repeatable.

### Customizing & Building the Image

To customize the Docker image:

1. Clone the repository and navigate to the directory with
   ```shell
   git clone https://github.com/jblab/docker-terragrunt.git
   cd docker-terragrunt
   ```   
2. Make your changes
3. Build the Docker image with:
   ```shell
   docker build -t <your-image-name>:<tag> .
   ```

## Breaking Changes
Please consult `BREAKING_CHANGES.md` for more information about version history and compatibility.

## Contributing

Contributions are welcome. Check for any open issues or create a new one to discuss your idea.

## License

The project is licensed under the Apache 2.0 License - refer to the `LICENSE` file for details.
