# docker-terragrunt <img src="https://assets.jblab.info/2024/03/17/jblab-logo-with-text.26da23672fc44c17078dc8ce2ff8495ddb190163.webp" alt="jblab logo" width="120" align="right" style="max-width: 100%">

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square)](LICENSE) [![Latest Release](https://img.shields.io/github/release/jblab/docker-terragrunt.svg?style=flat-square)](https://github.com/jblab/docker-terragrunt/releases/latest) ![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/jblab/docker-terragrunt/main.yml?style=flat-square)

This Docker image includes Terraform and Terragrunt, which are essential tools for managing infrastructure as code. It
can be used for local development to avoid managing different versions of these tools on your system or as part of your
CI/CD pipelines. The lightweight, Ubuntu-based image ensures that you run your pipelines in a consistent environment.

---

## How to Use

> [!IMPORTANT]
>
> We do not pin modules to versions in our examples because of the difficulty of keeping the versions in
> the documentation in sync with the latest released versions. We highly recommend that in your code you pin the version
> to the exact version you are using so that your infrastructure remains stable, and update versions in a systematic way
> so that they do not catch you by surprise.

Pull the Docker image from the Docker Hub:

```shell
docker pull jbonnier/terragrunt:latest
```

To run the terraform command:

```shell
docker run -it --rm jbonnier/terragrunt:latest terraform -version
```

To run the terragrunt command:

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
