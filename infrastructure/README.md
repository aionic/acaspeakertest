# Bicep Infrastructure as Code Project

This project provides a modular, parameterized Bicep solution for deploying core Azure resources using best practices for naming, security, and automation.

## Project Structure
- `bicep/main.bicep` - Main entry point for deployment (uses modules and seed-based naming)
- `bicep/main.parameters.json` - Example parameters file (set your `seed` and `location`)
- `bicep/modules/` - Reusable Bicep modules for each resource type
- `bicep/deploy.ps1` - PowerShell deployment script for easy deployment

## Prerequisites
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Bicep CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
- Sufficient Azure RBAC permissions (Owner, Contributor, or User Access Administrator)

## Naming Conventions
All resource names are generated from a single `seed` parameter, ensuring uniqueness and compliance with Azure naming rules:
- Log Analytics Workspace: `law-<seed>`
- Container App Environment: `cae-<seed>`
- Container Registry: `cr<seed>` (lowercase, alphanumeric)
- User Assigned Identity: `id-<seed>`
- Container App: `ca-<seed>`

## Deployment Instructions
1. **Configure Parameters**
   - Edit `bicep/main.parameters.json` and set your desired `seed` and `location`.
   - Example:
     ```json
     {
       "parameters": {
         "seed": { "value": "dev01" },
         "location": { "value": "eastus2" }
       }
     }
     ```
2. **Deploy**
   - Use the provided PowerShell script to deploy:
     ```pwsh
     cd .\bicep
     ./deploy.ps1 -ResourceGroupName <your-rg>
     ```

3. **Manual Deployment (optional)**
   - You can also deploy manually with Azure CLI:
     ```sh
     az deployment group create --resource-group <your-rg> --template-file main.bicep --parameters @main.parameters.json
     ```

## Best Practices Followed
- **Modular Bicep**: Each resource type is a separate module for reusability and clarity.
- **Parameterization**: All environment-specific values are parameters.
- **Seed-based Naming**: Ensures unique, compliant names for all resources.
- **RBAC Principle of Least Privilege**: Proper identity and access management patterns.
- **Stable API Versions**: Uses latest stable (non-preview) API versions for all resources.
- **Comprehensive Outputs**: Provides key resource identifiers for downstream automation.

## Customization
- Add or modify modules in `bicep/modules/` as needed for your solution.
- Adjust naming conventions in `main.bicep` if your organization has specific requirements.

## Support
For questions or improvements, open an issue or submit a pull request.
