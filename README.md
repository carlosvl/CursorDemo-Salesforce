# CursorDemo-Salesforce

A Salesforce DX project for demonstration purposes, showcasing best practices for Salesforce development and GitHub distribution.

## Project Structure

This project follows the standard Salesforce DX project structure:

- `force-app/` - Contains the source code for your Salesforce application
- `config/` - Project configuration files including scratch org definitions
- `scripts/` - Utility scripts for development tasks
- `sfdx-project.json` - Main project configuration file

## Prerequisites

Before working with this project, ensure you have:

- [Salesforce CLI](https://developer.salesforce.com/tools/sfdxcli) installed
- [Node.js](https://nodejs.org/) (LTS version recommended)
- [Git](https://git-scm.com/) for version control
- [Visual Studio Code](https://code.visualstudio.com/) with [Salesforce Extensions](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)

## Getting Started

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd CursorDemo-Salesforce
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Authorize your Dev Hub (if not already done):
   ```bash
   sf org login web --set-default-dev-hub
   ```

4. Create a scratch org:
   ```bash
   sf org create scratch --definition-file config/project-scratch-def.json --alias demo-org --set-default
   ```

5. Push source to the scratch org:
   ```bash
   sf project deploy start
   ```

6. Open the scratch org:
   ```bash
   sf org open
   ```

## Development Workflow

This project uses the scratch org development model. Key commands:

- `sf project deploy start` - Deploy changes to your scratch org
- `sf project retrieve start` - Retrieve changes from your scratch org
- `npm test` - Run unit tests
- `npm run lint` - Run ESLint code analysis

## Contributing

1. Create a feature branch from `main`
2. Make your changes
3. Run tests and linting
4. Submit a pull request

## Resources

- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
- [Salesforce Extensions for VS Code](https://developer.salesforce.com/tools/vscode/)
