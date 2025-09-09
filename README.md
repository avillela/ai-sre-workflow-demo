# Adriana's AI Orchestration Playground

Adriana's amazing AI orchestration playground using [Codename Goose](https://block.github.io/goose/docs).

See [quick start guide](https://block.github.io/goose/docs/quickstart/).

Goose's configuration files are located under `~/.config/goose`

## Setup

1- Download and install Goose

```bash
export $(dbus-launch)
gnome-keyring-daemon --start --components=secrets
echo "blah" | gnome-keyring-daemon -r --unlock --components=secret
curl -fsSL https://github.com/block/goose/releases/download/v1.7.0/download_cli.sh | bash
```

To update configurations after initial installation, run `goose configure` or `goose-configure`.

2- Choose provider

Under `What would you like to configure?` choose `Configure Providers`, and select `Github Copilot`. Follow the prompts on the screen.

3- Add extensions (MCP servers)

You can add the MCP servers (extensions, in Goose terminology) required by your project to the Goose [`config.yaml`](~/.config/goose/config.yaml) file.

For your conveniennce, the Goose [`config.yaml`](~/.config/goose/config.yaml) required to run this example is included in this repo. All you need to do is copy it over to the appropriate location by running:

```bash
cp src/config/goose/config.yaml ~/.config/goose/config.yaml
```

You also need to populate the environment variables required by the Dynatrace MCP server. To do so:

```bash
cp src/config/goose/.env.temmplate src/config/goose/.env
```

And fill out the values of the environment variables.

MCP Servers used:

1. [Dynatrace MCP Server](https://github.com/dynatrace-oss/dynatrace-mcp): interact with Dynatrace
2. [GitHub MCP Server](https://github.com/github/github-mcp-server): interact with the GitHub API
3. [CLI MCP Server](https://github.com/MladenSU/cli-mcp-server): allows for command line execution

3- Start a new session & prompt away!

Start a new session

```bash
export $(grep -v '^#' src/config/goose/.env | xargs) && goose session
```

Enter your prompt(s) in the command line. Example prompt

## Running recipes

Recipes are reusable prompts. Recipes in this repo live in [`recipes`](/recipes/). There's a sample starter recipe from the Goose docs called `trip.yaml`.

To start a receipe:

```bash
export $(grep -v '^#' src/config/goose/.env | xargs) && goose run --recipe src/recipes/<recipe_name>.yaml
```

## Prompts

1. create a kind cluster called otel
2. install argocd in the newly-created kind cluster 

## Run this example

```bash
export $(grep -v '^#' src/config/goose/.env | xargs) && \
  goose run --recipe src/recipes/k8s-setup.yaml

export $(grep -v '^#' src/config/goose/.env | xargs) && \
  goose run --recipe src/recipes/argo-admin.yaml \
  --params argocd_password=$ARGOCD_PASSWORD \
  --params argocd_url=$ARGOCD_URL \
  --params argocd_username=$ARGOCD_USERNAME
```

## High-level setup

1. Install Goose
2. Configure Goose with GitHub Copilot as provider
3. Configure MCP servers (extensions)
4. Create a project
5. Create recipe(s) for project


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
mv ~/.local/config/goose ~/.local/config/goose-bak
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

Then re-add your previous [config.yaml](~/.config/goose/config.yaml) back:

```bash
cp ~/.config/goose-bak/config.yaml ~/.config/goose/config.yaml
rm -rf ~/.config/goose-bak
```


## Resources

* [Goosehints](https://block.github.io/goose/docs/guides/using-goosehints/)
* [Goose CLI reference](https://block.github.io/goose/docs/guides/goose-cli-commands)
* [Goose recipes](https://block.github.io/goose/docs/guides/recipes/)
* [MCP Server registry](https://github.com/modelcontextprotocol/servers?tab=readme-ov-file#-third-party-servers)