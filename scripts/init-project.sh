#!/usr/bin/env bash
set -e

source scripts/config.env
./scripts/validate-env.sh

create_repo () {
  gh repo create "$ORG_NAME/$1" \
    --template "$ORG_NAME/$2" \
    --$VISIBILITY \
    --confirm
}

create_repo "$PROJECT_NAME-core" "$TEMPLATE_CORE"
create_repo "$PROJECT_NAME-application" "$TEMPLATE_APPLICATION"
create_repo "$PROJECT_NAME-infrastructure" "$TEMPLATE_INFRASTRUCTURE"
create_repo "$PROJECT_NAME-interface" "$TEMPLATE_INTERFACE"
create_repo "$PROJECT_NAME-docs" "$TEMPLATE_DOCS"

git submodule add "https://github.com/$ORG_NAME/$PROJECT_NAME-core" core
git submodule add "https://github.com/$ORG_NAME/$PROJECT_NAME-application" application
git submodule add "https://github.com/$ORG_NAME/$PROJECT_NAME-infrastructure" infrastructure
git submodule add "https://github.com/$ORG_NAME/$PROJECT_NAME-interface" interface
git submodule add "https://github.com/$ORG_NAME/$PROJECT_NAME-docs" docs

git commit -m "chore(project): initialize modular project structure"
