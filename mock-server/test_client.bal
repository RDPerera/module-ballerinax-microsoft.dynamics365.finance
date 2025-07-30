import ballerina/io;
import ballerina/http;

public function main() returns error? {
    // Create an HTTP client to test the mock server
    http:Client httpClient = check new("http://localhost:9090");
    
    io:println("🚀 Testing Dynamics 365 Finance Mock Server");
    io:println("============================================");
    
    // Test 1: Get server info
    io:println("\n1. Getting server info...");
    json serverInfo = check httpClient->get("/data");
    io:println("Server info: ", serverInfo);
    
    // Test 2: Get all customers
    io:println("\n2. Getting all customers...");
    json customers = check httpClient->get("/CustomersV3");
    io:println("Customers found: ", customers);
    
    // Test 3: Get filtered customers
    io:println("\n3. Getting filtered customers...");
    json filteredCustomers = check httpClient->get("/CustomersV3?$filter=CustomerAccount eq 'CUST-001'");
    io:println("Filtered customers: ", filteredCustomers);
    
    // Test 4: Get customer count
    io:println("\n4. Getting customer count...");
    int customerCount = check httpClient->get("/CustomersV3/$count");
    io:println("Total customers: ", customerCount);
    
    // Test 5: Get all products
    io:println("\n5. Getting all products...");
    json products = check httpClient->get("/ReleasedProductsV2");
    io:println("Products found: ", products);
    
    // Test 6: Get exchange rates
    io:println("\n6. Getting exchange rates...");
    json rates = check httpClient->get("/ExchangeRates");
    io:println("Exchange rates: ", rates);
    
    // Test 7: Get vendor groups
    io:println("\n7. Getting vendor groups...");
    json vendorGroups = check httpClient->get("/VendorGroups");
    io:println("Vendor groups: ", vendorGroups);
    
    // Test 8: Get system users
    io:println("\n8. Getting system users...");
    json users = check httpClient->get("/SystemUsers");
    io:println("System users: ", users);
    
    // Test 9: Create a new customer
    io:println("\n9. Creating a new customer...");
    json newCustomer = {
        "dataAreaId": "USMF",
        "CustomerName": "Test Customer Ltd",
        "CustomerGroupId": "10",
        "CurrencyCode": "USD"
    };
    json createResult = check httpClient->post("/CustomersV3", newCustomer);
    io:println("Customer creation result: ", createResult);
    
    // Test 10: Get OData metadata
    io:println("\n10. Getting OData metadata...");
    xml metadata = check httpClient->get("/$metadata");
    io:println("Metadata (first 200 chars): ", metadata.toString().substring(0, 200) + "...");
    
    io:println("\n✅ All tests completed successfully!");
    io:println("Mock server is working correctly and ready for testing your Dynamics 365 Finance connector.");
}
