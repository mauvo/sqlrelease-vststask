# SQL Release - VSTS Task

These are the VSTS tasks for SQL Release.

## Tasks

There is one task. There are four actions, similar to the Octopus Deploy step templates.

## Structure
- extension-manifest.json defines most of the metadata about the plugin.
- images\ is various images shown in the marketplace. These are referenced by extensions-manifest.json.
- overview.md is a markdown file. This is the text shown in the marketplace.
- TheTask\task.json defines the task.
- TheTask\RunSqlRelease.ps1 is the PowerShell run by the task.

## Development

1. Install Node.
2. Install the latest DLM Automation Suite.
3. Run build.bat to build the VSIX package.
4. Upload to the Marketplace and use it.

# Contact

Speak to Jason Crease about this project.
