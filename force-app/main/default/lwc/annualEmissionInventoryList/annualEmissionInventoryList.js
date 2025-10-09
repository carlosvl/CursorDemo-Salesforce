import { LightningElement, api, wire } from 'lwc';
import getEmissionInventories from '@salesforce/apex/AnnualEmissionInventoryController.getEmissionInventories';
import { refreshApex } from '@salesforce/apex';

export default class AnnualEmissionInventoryList extends LightningElement {
    @api recordId; // Account record ID passed from the page context
    
    emissionInventories = [];
    error;
    wiredResult;

    // Define columns for the data table
    columns = [
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
                recordUrl: `/${record.id}`,
                formattedYear: record.reportingYear ? record.reportingYear.toString() : ''
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.emissionInventories = [];
            console.error('Error loading emission inventories:', error);
        }
    }

    get hasRecords() {
        return this.emissionInventories && this.emissionInventories.length > 0;
    }

    get cardTitle() {
        const count = this.emissionInventories ? this.emissionInventories.length : 0;
        return `Annual Emission Inventories (${count})`;
    }

    get isLoading() {
        return this.wiredResult === undefined;
    }

    // Method to refresh data if needed
    handleRefresh() {
        return refreshApex(this.wiredResult);
    }
}
