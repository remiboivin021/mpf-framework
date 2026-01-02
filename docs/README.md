# MPF Documentation

This directory contains the documentation for the Modular Project Framework (MPF), built with [MkDocs](https://www.mkdocs.org/) and the [Material theme](https://squidfunk.github.io/mkdocs-material/).

## Local Development

### Prerequisites

- Python 3.x
- pip

### Installation

Install the required dependencies:

```bash
pip install -r ../requirements.txt
```

### Building the Documentation

Build the static site:

```bash
mkdocs build
```

The built site will be in the `site/` directory.

### Local Preview

Start a local development server with auto-reload:

```bash
mkdocs serve
```

The documentation will be available at `http://127.0.0.1:8000/`.

### Deployment

The documentation is automatically deployed to GitHub Pages when changes are pushed to the `main` branch. This is handled by the GitHub Actions workflow in `.github/workflows/deploy-docs.yml`.

## Structure

- `index.md` - Main landing page
- Additional documentation pages can be added as `.md` files
- Configuration is in `mkdocs.yml` at the repository root

## Writing Documentation

- Use standard Markdown syntax
- Follow the [Material for MkDocs reference](https://squidfunk.github.io/mkdocs-material/reference/) for advanced features
- Test your changes locally before committing

## Contributing

When adding new documentation pages:

1. Create the `.md` file in the appropriate location
2. Add it to the `nav` section in `mkdocs.yml`
3. Test locally with `mkdocs serve`
4. Commit and push to trigger automatic deployment
