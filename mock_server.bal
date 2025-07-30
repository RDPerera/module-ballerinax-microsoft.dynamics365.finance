import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/lang.runtime;

# Microsoft Dynamics 365 Finance Mock Server
public function main() returns error? {
    http:Listener httpListener = check new(9090);
    
    log:printInfo("🚀 Microsoft Dynamics 365 Finance Mock Server starting...");
    log:printInfo("Server will be available at: http://localhost:9090");
    
    http:Service mockService = service object {
        
        # Health check endpoint
        resource function get health() returns json {
            log:printInfo("Health check called");
            return {
                "status": "UP",
                "message": "Microsoft Dynamics 365 Finance Mock Server",
                "port": 9090,
                "timestamp": "2025-07-30T10:00:00Z"
            };
        }

        # Get customers - main endpoint for your connector
        resource function get CustomersV3(
            @http:Query {name: "$select"} string? selectFields,
            @http:Query {name: "cross-company"} string? crossCompany,
            @http:Query {name: "$filter"} string? filter
        ) returns json {
            log:printInfo("CustomersV3 endpoint called");
            json[] customers = [
                {
                    "dataAreaId": "USMF",
                    "CustomerAccount": "CUST-001",
                    "CustomerName": "Contoso Electronics",
                    "CustomerGroupId": "10",
                    "CurrencyCode": "USD",
                    "CreditLimit": 50000.00,
                    "PrimaryContactEmail": "contact@contoso.com"
                },
                {
                    "dataAreaId": "USMF",
                    "CustomerAccount": "CUST-002",
                    "CustomerName": "Fabrikam Manufacturing",
                    "CustomerGroupId": "20",
                    "CurrencyCode": "USD",
                    "CreditLimit": 75000.00,
                    "PrimaryContactEmail": "orders@fabrikam.com"
                }
            ];
            
            // Basic filtering support
            if filter is string && filter.includes("CUST-001") {
                customers = [customers[0]];
            }
            
            return {
                "@odata.context": "https://localhost:9090/$metadata#CustomersV3",
                "value": customers
            };
        }

        # Customer count
        resource function get CustomersV3/\$count() returns int {
            return 2;
        }

        # Get products
        resource function get ReleasedProductsV2(
            @http:Query {name: "$select"} string? selectFields,
            @http:Query {name: "cross-company"} string? crossCompany,
            @http:Query {name: "$filter"} string? filter
        ) returns json {
            log:printInfo("ReleasedProductsV2 endpoint called");
            return {
                "@odata.context": "https://localhost:9090/$metadata#ReleasedProductsV2",
                "value": [
                    {
                        "dataAreaId": "USMF",
                        "ItemNumber": "ITEM-001",
                        "ProductName": "Surface Pro Tablet",
                        "ProductType": "Item",
                        "SalesPrice": 999.99,
                        "PurchasePrice": 750.00
                    },
                    {
                        "dataAreaId": "USMF",
                        "ItemNumber": "ITEM-002",
                        "ProductName": "Wireless Mouse",
                        "ProductType": "Item",
                        "SalesPrice": 29.99,
                        "PurchasePrice": 15.00
                    }
                ]
            };
        }

        # Create customer
        resource function post CustomersV3(@http:Payload json payload) returns json {
            log:printInfo("Creating new customer");
            return {
                "message": "Customer created successfully",
                "customerAccount": "CUST-NEW-001",
                "timestamp": "2025-07-30T10:00:00Z",
                "data": payload
            };
        }

        # Server info
        resource function get data() returns json {
            return {
                "message": "Microsoft Dynamics 365 Finance Mock Server",
                "version": "1.0.0",
                "port": 9090,
                "status": "running",
                "endpoints": [
                    "GET /health - Health check",
                    "GET /CustomersV3 - Get customers",
                    "GET /CustomersV3/$count - Customer count",
                    "POST /CustomersV3 - Create customer",
                    "GET /ReleasedProductsV2 - Get products"
                ]
            };
        }
    };
    
    check httpListener.attach(mockService, "/");
    check httpListener.'start();
    
    io:println("✅ Mock server started successfully!");
    io:println("📍 Health check: http://localhost:9090/health");
    io:println("👥 Customers: http://localhost:9090/CustomersV3");
    io:println("📦 Products: http://localhost:9090/ReleasedProductsV2");
    io:println("ℹ️  Server info: http://localhost:9090/data");
    io:println("");
    io:println("🔄 Press Ctrl+C to stop the server");
    
    runtime:sleep(365 * 24 * 60 * 60); // Keep running for a year
}
