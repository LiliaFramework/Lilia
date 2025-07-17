# gmod-upload

This is an action to upload a Garry's Mod addon to the steam workshop.

## Example

```yaml
name: Deploy to Workshop

on:
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@master
      - uses: vurv78/gmod-upload@master
        with:
          id: 2466875474
          changelog: "Deployment via Github to latest changes"
        env:
          STEAM_USERNAME: ${{ secrets.STEAM_USERNAME }}
          STEAM_PASSWORD: ${{ secrets.STEAM_PASSWORD }}
```

Taken from https://github.com/Vurv78/WebAudio/blob/main/.github/workflows/deploy.yml