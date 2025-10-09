/**
 * @description Apex controller for Annual Emission Inventory List LWC
 * @author Salesforce Developer
 * @version 1.0
 */
public with sharing class AnnualEmissionInventoryController {
    
    /**
     * @description Retrieves Annual Emission Inventory records related to the specified Account
     * @param accountId The Account record ID
     * @return List of Annual Emission Inventory records
     */
    @AuraEnabled(cacheable=true)
    public static List<AnnualEmssnInventoryWrapper> getEmissionInventories(String accountId) {
        try {
            if (String.isBlank(accountId)) {
                throw new AuraHandledException('Account ID is required');
            }

            // Check read access for Annual Emission Inventory object
            if (!Schema.sObjectType.AnnualEmssnInventory.isAccessible()) {
                throw new AuraHandledException('You do not have permission to access Annual Emission Inventory records');
            }

            // Query Annual Emission Inventory records
            // Using actual Net Zero Cloud field names
            List<AnnualEmssnInventory> inventories = [
                SELECT Id, Name, Year, LastModifiedDate, 
                       CreatedDate, LastModifiedBy.Name, Owner.Name,
                       TotalScope1Emissions, TotalScope2Emissions, TotalScope3Emissions,
                       FinalEmssnInTco2e
                FROM AnnualEmssnInventory 
                WHERE AccountNameId = :accountId 
                ORDER BY Year DESC, CreatedDate DESC
                LIMIT 50
            ];

            // Convert to wrapper for better data handling
            List<AnnualEmssnInventoryWrapper> wrapperList = new List<AnnualEmssnInventoryWrapper>();
            for (AnnualEmssnInventory inventory : inventories) {
                wrapperList.add(new AnnualEmssnInventoryWrapper(inventory));
            }

            return wrapperList;

        } catch (QueryException qe) {
            System.debug('Query Exception in getEmissionInventories: ' + qe.getMessage());
            throw new AuraHandledException('Error querying emission inventories: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug('Exception in getEmissionInventories: ' + e.getMessage());
            throw new AuraHandledException('Unexpected error occurred: ' + e.getMessage());
        }
    }

    /**
     * @description Wrapper class for Annual Emission Inventory to handle null values
     * and provide additional computed properties
     */
    public class AnnualEmssnInventoryWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Integer reportingYear { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public DateTime lastModifiedDate { get; set; }
        @AuraEnabled public String lastModifiedBy { get; set; }
        @AuraEnabled public String owner { get; set; }
        @AuraEnabled public String formattedStatus { get; set; }
        @AuraEnabled public Decimal totalScope1Emissions { get; set; }
        @AuraEnabled public Decimal totalScope2Emissions { get; set; }
        @AuraEnabled public Decimal totalScope3Emissions { get; set; }
        @AuraEnabled public Decimal finalEmissions { get; set; }

        public AnnualEmssnInventoryWrapper(AnnualEmssnInventory inventory) {
            this.id = inventory.Id;
            this.name = inventory.Name != null ? inventory.Name : '';
            this.reportingYear = inventory.Year != null ? Integer.valueOf(inventory.Year) : null;
            this.status = 'Active'; // Default status since no Status field exists
            this.lastModifiedDate = inventory.LastModifiedDate;
            this.lastModifiedBy = inventory.LastModifiedBy?.Name != null ? inventory.LastModifiedBy.Name : '';
            this.owner = inventory.Owner?.Name != null ? inventory.Owner.Name : '';
            this.formattedStatus = this.status;
            this.totalScope1Emissions = inventory.TotalScope1Emissions;
            this.totalScope2Emissions = inventory.TotalScope2Emissions;
            this.totalScope3Emissions = inventory.TotalScope3Emissions;
            this.finalEmissions = inventory.FinalEmssnInTco2e;
        }
    }
}
