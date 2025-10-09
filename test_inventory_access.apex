/**
 * @description Simple test to verify Annual Emissions Inventory access
 * Run this from Anonymous Apex in Developer Console
 */

// Test basic object access
try {
    System.debug('=== Testing Annual Emissions Inventory Access ===');
    
    // Test object accessibility
    if (Schema.sObjectType.AnnualEmssnInventory.isAccessible()) {
        System.debug('✅ User has READ access to AnnualEmssnInventory');
        
        // Test basic query
        List<AnnualEmssnInventory> inventories = [
            SELECT Id, Name, Year, AccountNameId
            FROM AnnualEmssnInventory 
            LIMIT 5
        ];
        
        System.debug('✅ Query successful! Found ' + inventories.size() + ' records');
        
        for (AnnualEmssnInventory inv : inventories) {
            System.debug('  - ' + inv.Name + ' (Year: ' + inv.Year + ', Account: ' + inv.AccountNameId + ')');
        }
        
        // Test specific account query
        String testAccountId = '001B000001Th8GgIAJ';
        List<AnnualEmssnInventory> accountInventories = [
            SELECT Id, Name, Year
            FROM AnnualEmssnInventory 
            WHERE AccountNameId = :testAccountId
            LIMIT 5
        ];
        
        System.debug('✅ Found ' + accountInventories.size() + ' inventories for Account: ' + testAccountId);
        
    } else {
        System.debug('❌ User does NOT have READ access to AnnualEmssnInventory');
        System.debug('   Please check object permissions and sharing settings');
    }
    
} catch (Exception e) {
    System.debug('❌ Error accessing AnnualEmssnInventory: ' + e.getMessage());
    System.debug('   Error Type: ' + e.getTypeName());
    System.debug('   Stack Trace: ' + e.getStackTraceString());
}
