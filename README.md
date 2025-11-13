# Adriana's AI Orchestration Playground

Adriana's amazing AI orchestration playground using [Codename Goose](https://block.github.io/goose/docs).

See [quick start guide](https://block.github.io/goose/docs/quickstart/).

Goose's configuration files are located under `~/.config/goose`

## High-level setup

1. Install Goose
2. Configure Goose with GitHub Copilot as provider
3. Configure MCP servers (extensions)
4. Create a project
5. Create recipe(s) for project

MCP Servers used:

1. [Developer Extension (built-in Goose extension for command-line execution)](https://block.github.io/goose/docs/mcp/developer-mcp/)
2. [Dynatrace MCP Server](https://github.com/dynatrace-oss/dynatrace-mcp): interact with Dynatrace
3. [ArgoCD MCP Server](https://github.com/akuity/argocd-mcp): create and list applications (FWIW, this wasn't super helpful to the overall workflow, so it wasn't used in the final solution)


## Setup

1- Download and install Goose

```bash
export $(dbus-launch)
gnome-keyring-daemon --start --components=secrets
echo "blah" | gnome-keyring-daemon -r --unlock --components=secret
curl -fsSL https://github.com/block/goose/releases/download/v1.7.0/download_cli.sh | bash
```

2- Choose provider

Under `What would you like to configure?` choose `Configure Providers`, and select `Github Copilot`. Follow the prompts on the screen.

3- Add extensions (MCP servers)

You can add the MCP servers (extensions, in Goose terminology) required by your project to the Goose [`config.yaml`](~/.config/goose/config.yaml) file.

For your conveniennce, the Goose [`config.yaml`](~/.config/goose/config.yaml) required to run this example is included in this repo. All you need to do is copy it over to the appropriate location by running:

```bash
cp src/goose/config/config.yaml ~/.config/goose/config.yaml
```

You also need to populate the environment variables required by the Dynatrace MCP server. To do so:

```bash
cp src/goose/config/.env.temmplate src/goose/config/.env
```

And fill out the values of the environment variables.

3- Start a new session & prompt away!

Start a new session

```bash
# Load environment variables to make them available to Goose, and then start Goose session
export $(grep -v '^#' src/goose/config/.env | xargs) && goose session
```

Enter your prompt(s) in the command line. Example prompt:

```text
How many folders do I have under the current directory? 
```

## Running recipes

Recipes are reusable prompts. Recipes in this repo live in [`recipes`](/recipes/). There's a sample starter recipe from the Goose docs called `trip.yaml`.

To run the sample recipe:

```bash
export $(grep -v '^#' src/goose/config/.env | xargs) && goose run --recipe src/recipes/trip.yaml
```

## Run the workflow

The commands below run the Goose recipes for bootstrapping Kubernetes (KinD) and ArgoCD, deploying the OTel Demo, and running natural language prompts to query OTel Demo data in Dynatrace.

```bash

# Create k8s KinD cluster
export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe src/goose/recipes/00-k8s-kind-cluster-create.yaml

# Create k8s GKE cluster
export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe src/goose/recipes/00-k8s-gke-cluster-create.yaml

# Install ArgoCD
export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe src/goose/recipes/01-argocd-install.yaml --params cluster_name=kind-otel

# Update the ArgoCD password
export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe src/goose/recipes/02-argocd-bootstrap.yaml

# Generate ArgoCD API token (to use ArgoCD MCP server)
export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe src/goose/recipes/03-argocd-api-token.yaml

# Deploy OTel Demo to k8s via ArgoCD
export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe src/goose/recipes/04-argo-apps-deploy.yaml

# Query OTel data in Dynatrace using natural language prompts
export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe src/goose/recipes/05-dynatrace-prompts.yaml

# FOR TESTING: Sub-recipes
export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe src/goose/recipes/sub_recipes/port-forward.yaml

export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe src/goose/recipes/sub_recipes/argocd-cli-install.yaml

export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe src/goose/recipes/sub_recipes/argocd-password-update.yaml

export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe src/goose/recipes/sub_recipes/argocd-api-token-config.yaml

export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe src/goose/recipes/sub_recipes/argocd-api-token-generation.yaml

export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe src/goose/recipes/sub_recipes/argo-repo-proj-setup.yaml

export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe src/goose/recipes/sub_recipes/deploy-otel-demo.yaml

export $(grep -v '^#' src/goose/config/.env | xargs) && \
  goose run --recipe  src/goose/recipes/sub_recipes/argo-mcp-test.yaml
```

## Gotchas

1- Malformed YAML Config

If [config.yaml](~/.config/goose/config.yaml) is malformed and you try to get Goose to list extentensions, it won't show any. Sometimes Goose will delete the contents of [config.yaml](~/.config/goose/config.yaml), so keep a backup somewhere.

> **NOTE:** To list extensions, run `goose configure` and then select `Toggle Extensions` from the menu.

2- Authentication error

If you get this error message:

```text
ERROR goose::session::storage: Failed to generate session description: Authentication error: Authentication failed. Please ensure your API keys are valid and have the required permissions. Status: 401 Unauthorized
```

Delete `~/.config/goose` and re-run `goose configure`. Then select `Configure Providers` -> `Github Copilot (Github Copilot and associated models)` -> `Yes`.


3- Failed to generate session description

If you get this error message:

```text
ERROR goose::session::storage: Failed to generate session description: Execution error: failed to get api info after 3 attempts
```

Then:

```bash
rm -rf ~/.local/share/keyrings
mkdir -p ~/.local/share/keyrings
touch ~/.local/share/keyrings/login.keyring
eval $(dbus-launch)
export $(dbus-launch)
gnome-keyring-daemon --start --components=secrets
echo "blah" | gnome-keyring-daemon -r --unlock --components=secret

goose configure
```

Follow same instructions to configure GitHub Copiolot with Goose.

4- Unreferenced paramters

If a recipe defines parameters, but they're not referenced anywhere in the prompt or instructions, then Goose will print out an error message like this:

```text
Error: Template rendering failed: 
Unnecessary parameter definitions: argocd_base_url, argocd_username, argocd_password.
```
Solution: remove unnecessary parameter definitions from the recipe YAML.

## Resources

* [Goosehints](https://block.github.io/goose/docs/guides/using-goosehints/)
* [Goose CLI reference](https://block.github.io/goose/docs/guides/goose-cli-commands)
* [Goose recipes](https://block.github.io/goose/docs/guides/recipes/)
* [MCP Server registry](https://github.com/modelcontextprotocol/servers?tab=readme-ov-file#-third-party-servers)