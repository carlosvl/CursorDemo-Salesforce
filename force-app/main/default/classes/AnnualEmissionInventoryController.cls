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
     * @description Retrieves Carbon Footprint records related to the specified Annual Emission Inventory
     * @param inventoryId The Annual Emission Inventory record ID
     * @return List of Carbon Footprint records from different sources
     */
    @AuraEnabled(cacheable=true)
    public static List<CarbonFootprintSummary> getCarbonFootprints(String inventoryId) {
        try {
            if (String.isBlank(inventoryId)) {
                throw new AuraHandledException('Inventory ID is required');
            }

            Map<String, CarbonFootprintSummary> summaryMap = new Map<String, CarbonFootprintSummary>();

            // 1. Get Stationary Asset Carbon Footprints
            if (Schema.sObjectType.StnryAssetCrbnFtprnt.isAccessible()) {
                List<StnryAssetCrbnFtprnt> stationaryFootprints = [
                    SELECT Id, Name, TotalScp3DnstrmEmissions, TotalScp3UpstrmEmissions,
                           CreatedDate, LastModifiedDate
                    FROM StnryAssetCrbnFtprnt 
                    WHERE AnnualEmssnInventoryId = :inventoryId
                    ORDER BY CreatedDate DESC
                ];

                if (!stationaryFootprints.isEmpty()) {
                    CarbonFootprintSummary summary = new CarbonFootprintSummary();
                    summary.type = 'Stationary Asset';
                    summary.recordCount = stationaryFootprints.size();
                    summary.totalEmissions = 0;
                    summary.scope1Emissions = 0;
                    summary.scope2Emissions = 0;
                    summary.scope3Emissions = 0;
                    
                    for (StnryAssetCrbnFtprnt footprint : stationaryFootprints) {
                        Decimal downstream = footprint.TotalScp3DnstrmEmissions != null ? footprint.TotalScp3DnstrmEmissions : 0;
                        Decimal upstream = footprint.TotalScp3UpstrmEmissions != null ? footprint.TotalScp3UpstrmEmissions : 0;
                        Decimal total = downstream + upstream;
                        summary.totalEmissions += total;
                        summary.scope3Emissions += total;
                    }
                    
                    summary.unit = 'tCO2e';
                    summary.lastModified = stationaryFootprints[0].LastModifiedDate;
                    summaryMap.put('Stationary Asset', summary);
                }
            }

            // 2. Get Vehicle Asset Carbon Footprints
            if (Schema.sObjectType.VehicleAssetCrbnFtprnt.isAccessible()) {
                List<VehicleAssetCrbnFtprnt> vehicleFootprints = [
                    SELECT Id, Name, TotalScp3DnstrmEmissions, TotalScp3UpstrmEmissions,
                           CreatedDate, LastModifiedDate
                    FROM VehicleAssetCrbnFtprnt 
                    WHERE AnnualEmssnInventoryId = :inventoryId
                    ORDER BY CreatedDate DESC
                ];

                if (!vehicleFootprints.isEmpty()) {
                    CarbonFootprintSummary summary = new CarbonFootprintSummary();
                    summary.type = 'Vehicle Asset';
                    summary.recordCount = vehicleFootprints.size();
                    summary.totalEmissions = 0;
                    summary.scope1Emissions = 0;
                    summary.scope2Emissions = 0;
                    summary.scope3Emissions = 0;
                    
                    for (VehicleAssetCrbnFtprnt footprint : vehicleFootprints) {
                        Decimal downstream = footprint.TotalScp3DnstrmEmissions != null ? footprint.TotalScp3DnstrmEmissions : 0;
                        Decimal upstream = footprint.TotalScp3UpstrmEmissions != null ? footprint.TotalScp3UpstrmEmissions : 0;
                        Decimal total = downstream + upstream;
                        summary.totalEmissions += total;
                        summary.scope3Emissions += total;
                    }
                    
                    summary.unit = 'tCO2e';
                    summary.lastModified = vehicleFootprints[0].LastModifiedDate;
                    summaryMap.put('Vehicle Asset', summary);
                }
            }

            // 3. Get Scope 3 Carbon Footprints
            if (Schema.sObjectType.Scope3CrbnFtprnt.isAccessible()) {
                List<Scope3CrbnFtprnt> scope3Footprints = [
                    SELECT Id, Name, CreatedDate, LastModifiedDate
                    FROM Scope3CrbnFtprnt 
                    WHERE AnnualEmssnInventoryId = :inventoryId
                    ORDER BY CreatedDate DESC
                ];

                if (!scope3Footprints.isEmpty()) {
                    CarbonFootprintSummary summary = new CarbonFootprintSummary();
                    summary.type = 'Scope 3';
                    summary.recordCount = scope3Footprints.size();
                    summary.totalEmissions = 0; // No total field available yet
                    summary.scope1Emissions = 0;
                    summary.scope2Emissions = 0;
                    summary.scope3Emissions = 0;
                    summary.unit = 'tCO2e';
                    summary.lastModified = scope3Footprints[0].LastModifiedDate;
                    summaryMap.put('Scope 3', summary);
                }
            }

            System.debug('Found ' + summaryMap.size() + ' carbon footprint types for inventory: ' + inventoryId);
            return summaryMap.values();

        } catch (QueryException qe) {
            System.debug('Query Exception in getCarbonFootprints: ' + qe.getMessage());
            throw new AuraHandledException('Error querying carbon footprints: ' + qe.getMessage());
        } catch (Exception e) {
            System.debug('Exception in getCarbonFootprints: ' + e.getMessage());
            throw new AuraHandledException('Unexpected error occurred: ' + e.getMessage());
        }
    }

    /**
     * @description Summary class for Carbon Footprint records grouped by type
     */
    public class CarbonFootprintSummary {
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public Integer recordCount { get; set; }
        @AuraEnabled public Decimal totalEmissions { get; set; }
        @AuraEnabled public Decimal scope1Emissions { get; set; }
        @AuraEnabled public Decimal scope2Emissions { get; set; }
        @AuraEnabled public Decimal scope3Emissions { get; set; }
        @AuraEnabled public String unit { get; set; }
        @AuraEnabled public DateTime lastModified { get; set; }
    }

    /**
     * @description Wrapper class for Carbon Footprint records from different objects
     */
    public class CarbonFootprintWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public Decimal totalEmissions { get; set; }
        @AuraEnabled public Decimal scope1Emissions { get; set; }
        @AuraEnabled public Decimal scope2Emissions { get; set; }
        @AuraEnabled public Decimal scope3Emissions { get; set; }
        @AuraEnabled public String unit { get; set; }
        @AuraEnabled public DateTime lastModified { get; set; }

        // Constructor for Stationary Asset Carbon Footprint
        public CarbonFootprintWrapper(StnryAssetCrbnFtprnt footprint, String footprintType) {
            this.id = footprint.Id;
            this.name = footprint.Name != null ? footprint.Name : 'Unnamed ' + footprintType;
            this.type = footprintType;
            
            // Calculate total from available fields
            Decimal downstream = footprint.TotalScp3DnstrmEmissions != null ? footprint.TotalScp3DnstrmEmissions : 0;
            Decimal upstream = footprint.TotalScp3UpstrmEmissions != null ? footprint.TotalScp3UpstrmEmissions : 0;
            this.totalEmissions = downstream + upstream;
            
            this.scope1Emissions = 0; // Not available in this object
            this.scope2Emissions = 0; // Not available in this object  
            this.scope3Emissions = this.totalEmissions; // Mostly scope 3 for stationary assets
            this.unit = 'tCO2e';
            this.lastModified = footprint.LastModifiedDate;
        }

        // Constructor for Vehicle Asset Carbon Footprint
        public CarbonFootprintWrapper(VehicleAssetCrbnFtprnt footprint, String footprintType) {
            this.id = footprint.Id;
            this.name = footprint.Name != null ? footprint.Name : 'Unnamed ' + footprintType;
            this.type = footprintType;
            
            // Calculate total from available fields
            Decimal downstream = footprint.TotalScp3DnstrmEmissions != null ? footprint.TotalScp3DnstrmEmissions : 0;
            Decimal upstream = footprint.TotalScp3UpstrmEmissions != null ? footprint.TotalScp3UpstrmEmissions : 0;
            this.totalEmissions = downstream + upstream;
            
            this.scope1Emissions = 0; // Not available in this object
            this.scope2Emissions = 0; // Not available in this object
            this.scope3Emissions = this.totalEmissions; // Mostly scope 3 for vehicles
            this.unit = 'tCO2e';
            this.lastModified = footprint.LastModifiedDate;
        }

        // Constructor for Scope 3 Carbon Footprint  
        public CarbonFootprintWrapper(Scope3CrbnFtprnt footprint, String footprintType) {
            this.id = footprint.Id;
            this.name = footprint.Name != null ? footprint.Name : 'Unnamed ' + footprintType;
            this.type = footprintType;
            this.totalEmissions = 0; // No total field available
            this.scope1Emissions = 0; // Scope 3 doesn't have Scope 1 emissions
            this.scope2Emissions = 0; // Scope 3 doesn't have Scope 2 emissions
            this.scope3Emissions = 0; // No specific field available yet
            this.unit = 'tCO2e';
            this.lastModified = footprint.LastModifiedDate;
        }
    }
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
