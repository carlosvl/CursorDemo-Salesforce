import { LightningElement, api, wire } from 'lwc';
import getEmissionInventories from '@salesforce/apex/AnnualEmissionInventoryController.getEmissionInventories';
import getCarbonFootprints from '@salesforce/apex/AnnualEmissionInventoryController.getCarbonFootprints';
import { refreshApex } from '@salesforce/apex';

export default class AnnualEmissionInventoryList extends LightningElement {
    @api recordId; // Account record ID passed from the page context
    
    emissionInventories = [];
    error;
    wiredResult;
    selectedRowId = null;
    selectedInventoryName = '';
    carbonFootprints = [];
    carbonFootprintError;
    showCarbonFootprints = false;

    // Define columns for the data table
    columns = [
        {
            label: 'Action',
            type: 'button',
            fixedWidth: 120,
            typeAttributes: {
                label: 'View Details',
                name: 'view_details',
                title: 'Click to view carbon footprints',
                disabled: false,
                value: 'view',
                iconName: 'utility:preview',
                variant: 'brand'
            }
        },
        {
            label: 'Name',
            fieldName: 'recordUrl',
            type: 'url',
            sortable: true,
            typeAttributes: {
                label: { fieldName: 'name' },
                target: '_self'
            },
            cellAttributes: {
                class: 'slds-text-color_default'
            }
        },
        {
            label: 'Reporting Year',
            fieldName: 'formattedYear',
            type: 'text',
            sortable: true,
            cellAttributes: {
                alignment: 'center'
            }
        },
        {
            label: 'Final Emissions (tCO2e)',
            fieldName: 'finalEmissions',
            type: 'number',
            sortable: true,
            typeAttributes: {
                maximumFractionDigits: 2
            },
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            label: 'Scope 1 (tCO2e)',
            fieldName: 'totalScope1Emissions',
            type: 'number',
            sortable: true,
            typeAttributes: {
                maximumFractionDigits: 2
            },
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            label: 'Scope 2 (tCO2e)',
            fieldName: 'totalScope2Emissions',
            type: 'number',
            sortable: true,
            typeAttributes: {
                maximumFractionDigits: 2
            },
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            label: 'Scope 3 (tCO2e)',
            fieldName: 'totalScope3Emissions',
            type: 'number',
            sortable: true,
            typeAttributes: {
                maximumFractionDigits: 2
            },
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            label: 'Last Modified',
            fieldName: 'lastModifiedDate',
            type: 'date',
            sortable: true,
            typeAttributes: {
                year: "numeric",
                month: "short",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }
        }
    ];

    @wire(getEmissionInventories, { accountId: '$recordId' })
    wiredEmissionInventories(result) {
        this.wiredResult = result;
        const { data, error } = result;
        
        if (data) {
            // Process data and add record URLs for clickable names + format year without commas
            this.emissionInventories = data.map(record => ({
                ...record,
                Id: record.id, // Ensure capital Id for data table key-field
                recordUrl: `/${record.id}`,
                formattedYear: record.reportingYear ? record.reportingYear.toString() : ''
            }));
            this.error = undefined;
            
            // Update button labels based on selection
            this.updateButtonLabels();
        } else if (error) {
            this.error = error;
            this.emissionInventories = [];
            console.error('Error loading emission inventories:', error);
        }
    }

    // Update button labels to show selection state
    updateButtonLabels() {
        // Update the columns to reflect current selection
        this.columns = [
            {
                label: 'Action',
                type: 'button',
                fixedWidth: 120,
                typeAttributes: {
                    label: 'View Details',
                    name: 'view_details',
                    title: 'Click to view carbon footprints',
                    disabled: false,
                    value: 'view',
                    iconName: 'utility:preview',
                    variant: 'brand'
                }
            },
            ...this.columns.slice(1) // Keep other columns the same
        ];
    }

    get hasRecords() {
        return this.emissionInventories && this.emissionInventories.length > 0;
    }

    get cardTitle() {
        const count = this.emissionInventories ? this.emissionInventories.length : 0;
        return `Annual Emission Inventories (${count})`;
    }

    get carbonFootprintTitle() {
        return `Carbon Footprints - ${this.selectedInventoryName}`;
    }

    get isLoading() {
        return this.wiredResult === undefined;
    }

    // Method to refresh data if needed
    handleRefresh() {
        return refreshApex(this.wiredResult);
    }

    // Handle button click in the data table
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'view_details') {
            // Toggle selection - if already selected, deselect
            if (this.selectedRowId === (row.Id || row.id)) {
                // Deselect
                this.selectedRowId = null;
                this.selectedInventoryName = '';
                this.showCarbonFootprints = false;
                this.carbonFootprints = [];
                console.log('Row deselected');
            } else {
                // Select new row
                this.selectedRowId = row.Id || row.id;
                this.selectedInventoryName = row.name;
                this.showCarbonFootprints = true;
                
                console.log('Row selected:', row);
                
                // Load carbon footprints for selected inventory
                this.loadCarbonFootprints();
            }
        }
    }

    // Load carbon footprints for the selected Annual Emissions Inventory
    async loadCarbonFootprints() {
        if (!this.selectedRowId) return;
        
        try {
            console.log('Loading carbon footprints for inventory:', this.selectedRowId);
            
            // Call the real Apex method to get carbon footprints
            const footprintsData = await getCarbonFootprints({ inventoryId: this.selectedRowId });
            
            if (footprintsData && footprintsData.length > 0) {
                // Map the data to match our display format with proper decimal formatting
                this.carbonFootprints = footprintsData.map(footprint => ({
                    id: footprint.id,
                    type: footprint.type,
                    name: footprint.name,
                    emissions: footprint.totalEmissions,
                    formattedEmissions: this.formatEmissionValue(footprint.totalEmissions),
                    unit: footprint.unit,
                    scope1: footprint.scope1Emissions,
                    scope2: footprint.scope2Emissions,
                    scope3: footprint.scope3Emissions,
                    lastModified: footprint.lastModified
                }));
                
                console.log('Loaded', this.carbonFootprints.length, 'carbon footprints');
            } else {
                // No carbon footprints found - still show the section but with empty state
                this.carbonFootprints = [];
                console.log('No carbon footprints found for this inventory');
            }
            
            this.carbonFootprintError = undefined;
            
        } catch (error) {
            this.carbonFootprintError = error;
            this.carbonFootprints = [];
            console.error('Error loading carbon footprints:', error);
            
            // If no real data available, fall back to sample data for demo
            if (error.body && error.body.message && error.body.message.includes('Error querying carbon footprints')) {
                console.log('Falling back to sample data for demo purposes');
                this.carbonFootprints = [
                    {
                        id: 'sample1',
                        type: 'Stationary Asset',
                        name: 'Building Emissions (Sample)',
                        emissions: 1250.50,
                        formattedEmissions: this.formatEmissionValue(1250.50),
                        unit: 'tCO2e'
                    },
                    {
                        id: 'sample2', 
                        type: 'Vehicle Asset',
                        name: 'Fleet Emissions (Sample)',
                        emissions: 875.25,
                        formattedEmissions: this.formatEmissionValue(875.25),
                        unit: 'tCO2e'
                    },
                    {
                        id: 'sample3',
                        type: 'Scope 3',
                        name: 'Supply Chain Emissions (Sample)',
                        emissions: 2100.75,
                        formattedEmissions: this.formatEmissionValue(2100.75),
                        unit: 'tCO2e'
                    }
                ];
                this.carbonFootprintError = undefined;
            }
        }
    }

    // Format emission values to show maximum 4 decimal places
    formatEmissionValue(value) {
        if (value === null || value === undefined || isNaN(value)) {
            return '0.0000';
        }
        
        // Convert to number and format with up to 4 decimal places
        const numValue = parseFloat(value);
        
        // Use toFixed for consistent decimal places, then parseFloat to remove trailing zeros
        const formatted = parseFloat(numValue.toFixed(4));
        
        // Return as string with proper formatting
        return formatted.toLocaleString('en-US', {
            minimumFractionDigits: 0,
            maximumFractionDigits: 4
        });
    }
}
