import ballerina/http;
import ballerina/log;

# Microsoft Dynamics 365 Finance Mock Server
service / on new http:Listener(9090) {

    # Health check endpoint
    resource function get health() returns json {
        log:printInfo("Health check called");
        return {
            "status": "UP",
            "message": "Microsoft Dynamics 365 Finance Mock Server",
            "timestamp": "2025-07-30T10:00:00Z"
        };
    }

    # Get customers - main endpoint you'll use with your connector
    resource function get CustomersV3(
        @http:Query {name: "$select"} string? selectFields,
        @http:Query {name: "cross-company"} string? crossCompany,
        @http:Query {name: "$filter"} string? filter
    ) returns json {
        log:printInfo("CustomersV3 endpoint called");
        return {
            "@odata.context": "https://localhost:9090/$metadata#CustomersV3",
            "value": [
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
            ]
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
        return {
            "@odata.context": "https://localhost:9090/$metadata#ReleasedProductsV2",
            "value": [
                {
                    "dataAreaId": "USMF",
                    "ItemNumber": "ITEM-001",
                    "ProductName": "Surface Pro Tablet",
                    "ProductType": "Item",
                    "SalesPrice": 999.99
                },
                {
                    "dataAreaId": "USMF",
                    "ItemNumber": "ITEM-002",
                    "ProductName": "Wireless Mouse",
                    "ProductType": "Item",
                    "SalesPrice": 29.99
                }
            ]
        };
    }

    # Create customer
    resource function post CustomersV3(@http:Payload json payload) returns json {
        return {
            "message": "Customer created successfully",
            "customerAccount": "CUST-NEW-001",
            "data": payload
        };
    }

    # Server info
    resource function get data() returns json {
        return {
            "message": "Microsoft Dynamics 365 Finance Mock Server",
            "version": "1.0.0",
            "endpoints": ["/CustomersV3", "/ReleasedProductsV2", "/health"]
        };
    }
}
