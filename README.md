# CursorDemo-Salesforce

A Salesforce DX project containing automated solutions for Net Zero Cloud and other Salesforce implementations. This repository showcases best practices for Salesforce development, Flow automation, and GitHub distribution.

## Project Structure

This project follows the standard Salesforce DX project structure:

- `force-app/` - Contains the source code for your Salesforce application
- `config/` - Project configuration files including scratch org definitions
- `scripts/` - Utility scripts for development tasks
- `sfdx-project.json` - Main project configuration file

## 🚀 Solutions Included

This repository contains the following automated solutions:

### 1. 🏢 Stationary Asset Type Automation
**File:** `force-app/main/default/flows/Update_Stationary_Asset_Type_Flow.flow-meta.xml`

A Record-Triggered Flow that automatically updates the "Stationary Asset Type" field to "Office" on Stationary Environmental Source records when the "Business Unit" field is set to "Full Corporate". 

**Features:**
- Executes on record creation and updates
- Before-save trigger for optimal performance
- Automatic field population based on business rules

### 2. 🚖 Simple Distance-Based Taxi Trip Logger
**File:** `force-app/main/default/flows/Simple_Distance_Based_Taxi_Trip_Logger.flow-meta.xml`

A Screen Flow solution that simplifies taxi trip logging in Net Zero Cloud by eliminating the complex Vehicle Asset workaround that was previously required for distance-based entries.

**Features:**
- Educational screens explaining the new simplified process
- User-friendly input form for trip details
- Automatic creation of GroundTravelEnrgyUse records
- Eliminates technical debt from complex workarounds

**Documentation:** See `TAXI_TRIP_SOLUTION.md` for detailed implementation guide.

### 3. 📋 Technical Documentation
**File:** `TAXI_TRIP_SOLUTION.md`

Comprehensive documentation covering:
- Problem analysis and solution approach
- Implementation methods (CLI, UI, Flow)
- Testing instructions and verification steps
- Benefits and success metrics
- Migration guidance from old complex processes

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

## 🔧 Deploying Individual Solutions

To deploy specific solutions to your org:

### Deploy Stationary Asset Type Flow:
```bash
sf project deploy start --source-dir force-app/main/default/flows/Update_Stationary_Asset_Type_Flow.flow-meta.xml
```

### Deploy Taxi Trip Logger Flow:
```bash
sf project deploy start --source-dir force-app/main/default/flows/Simple_Distance_Based_Taxi_Trip_Logger.flow-meta.xml
```

### Deploy All Flows:
```bash
sf project deploy start --source-dir force-app/main/default/flows/
```

## Development Workflow

This project uses the scratch org development model. Key commands:

- `sf project deploy start` - Deploy changes to your scratch org
- `sf project retrieve start` - Retrieve changes from your scratch org
- `npm test` - Run unit tests
- `npm run lint` - Run ESLint code analysis

## 🤝 Contributing

Contributions are welcome! Whether you're fixing bugs, improving existing solutions, or adding new automated solutions:

1. Create a feature branch from `main`
2. Make your changes
3. Test your solutions thoroughly
4. Update documentation (including this README if adding new solutions)
5. Run tests and linting
6. Submit a pull request

### Adding New Solutions
When contributing new solutions, please:
- Include comprehensive documentation
- Add the solution to this README's "Solutions Included" section
- Provide deployment instructions
- Include testing guidance

## 📚 Resources

### General Salesforce Development
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
- [Salesforce Extensions for VS Code](https://developer.salesforce.com/tools/vscode/)

### Flow Development
- [Flow Builder Documentation](https://help.salesforce.com/s/articleView?id=sf.flow.htm)
- [Record-Triggered Flows](https://help.salesforce.com/s/articleView?id=sf.flow_concepts_trigger.htm)
- [Screen Flows](https://help.salesforce.com/s/articleView?id=sf.flow_concepts_screen_flow.htm)

### Net Zero Cloud Specific
- [Net Zero Cloud Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.netzero_cloud_dev_guide.meta/netzero_cloud_dev_guide/netzero_cloud_std_objects_intro.htm)
- [Net Zero Cloud Object Reference](https://developer.salesforce.com/docs/atlas.en-us.netzero_cloud_dev_guide.meta/netzero_cloud_dev_guide/netzero_cloud_objects.htm)

---

**💡 Need Help?** Check the individual solution documentation files in this repository for detailed implementation guidance and troubleshooting tips.
