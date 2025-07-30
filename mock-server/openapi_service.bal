import ballerina/http;
import ballerina/uuid;
import ballerina/time;

listener http:Listener ep0 = new (9090, config = {host: "localhost"});

# Mock data store for different entities
map<json> mockCustomers = {
    "CUST-001": {
        "dataAreaId": "USMF",
        "CustomerAccount": "CUST-001",
        "CustomerName": "Contoso Electronics",
        "CustomerGroupId": "10",
        "AccountReceivableAccountDisplayValue": "130100-001--",
        "PrimaryContactEmail": "contact@contoso.com",
        "PrimaryContactPhone": "+1-555-0123",
        "InvoiceAccountId": "CUST-001",
        "CurrencyCode": "USD",
        "CreditLimit": 50000.00,
        "PaymentTermsName": "Net30"
    },
    "CUST-002": {
        "dataAreaId": "USMF", 
        "CustomerAccount": "CUST-002",
        "CustomerName": "Fabrikam Manufacturing",
        "CustomerGroupId": "20",
        "AccountReceivableAccountDisplayValue": "130100-002--",
        "PrimaryContactEmail": "orders@fabrikam.com",
        "PrimaryContactPhone": "+1-555-0456",
        "InvoiceAccountId": "CUST-002",
        "CurrencyCode": "USD",
        "CreditLimit": 75000.00,
        "PaymentTermsName": "Net15"
    }
};

map<json> mockVendors = {
    "VEND-001": {
        "dataAreaId": "USMF",
        "VendorAccount": "VEND-001", 
        "VendorName": "Alpine Ski House",
        "VendorGroupId": "10",
        "AccountPayableAccountDisplayValue": "200100-001--",
        "PrimaryContactEmail": "supplier@alpine.com",
        "PrimaryContactPhone": "+1-555-0789",
        "InvoiceAccountId": "VEND-001",
        "CurrencyCode": "USD",
        "PaymentTermsName": "Net30"
    },
    "VEND-002": {
        "dataAreaId": "USMF",
        "VendorAccount": "VEND-002",
        "VendorName": "City Power & Light", 
        "VendorGroupId": "20",
        "AccountPayableAccountDisplayValue": "200100-002--",
        "PrimaryContactEmail": "billing@citypower.com",
        "PrimaryContactPhone": "+1-555-0321",
        "InvoiceAccountId": "VEND-002",
        "CurrencyCode": "USD",
        "PaymentTermsName": "Net15"
    }
};

map<json> mockProducts = {
    "ITEM-001": {
        "dataAreaId": "USMF",
        "ItemNumber": "ITEM-001",
        "ProductName": "Surface Pro Tablet",
        "ProductType": "Item",
        "ItemModelGroupId": "StdCost",
        "ItemGroupId": "Audio",
        "StorageDimensionGroupName": "SiteWH",
        "TrackingDimensionGroupName": "None",
        "SalesUnitSymbol": "ea",
        "PurchaseUnitSymbol": "ea",
        "InventoryUnitSymbol": "ea",
        "SalesPrice": 999.99,
        "PurchasePrice": 750.00
    },
    "ITEM-002": {
        "dataAreaId": "USMF",
        "ItemNumber": "ITEM-002", 
        "ProductName": "Wireless Mouse",
        "ProductType": "Item",
        "ItemModelGroupId": "StdCost",
        "ItemGroupId": "Computer",
        "StorageDimensionGroupName": "SiteWH",
        "TrackingDimensionGroupName": "None",
        "SalesUnitSymbol": "ea",
        "PurchaseUnitSymbol": "ea", 
        "InventoryUnitSymbol": "ea",
        "SalesPrice": 29.99,
        "PurchasePrice": 15.00
    }
};

service / on ep0 {
    # GetCustomerGroups_CrossCompany
    resource function get CustomerGroups(@http:Query {name: "cross-company"} string? crossCompany) returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#CustomerGroups",
            "value": [
                {
                    "dataAreaId": "USMF",
                    "CustomerGroupId": "10", 
                    "Description": "Wholesale Customers",
                    "PaymentTermsId": "Net30",
                    "DefaultDimensionDisplayValue": "BusinessUnit--"
                },
                {
                    "dataAreaId": "USMF",
                    "CustomerGroupId": "20",
                    "Description": "Retail Customers", 
                    "PaymentTermsId": "Net15",
                    "DefaultDimensionDisplayValue": "BusinessUnit--"
                }
            ]
        };
    }

    # GetCustomerPaymentJournalHeaders_CrossCompany  
    resource function get CustomerPaymentJournalHeaders(@http:Query {name: "cross-company"} string? crossCompany) returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#CustomerPaymentJournalHeaders",
            "value": [
                {
                    "dataAreaId": "USMF",
                    "JournalBatchNumber": "CustPay-001",
                    "Name": "Customer Payment Journal",
                    "Description": "Daily customer payments",
                    "JournalType": "CustPaym",
                    "VoucherSeries": "CustPay",
                    "PostedDateTime": "2025-07-30T10:00:00Z",
                    "PostedBy": "admin"
                }
            ]
        };
    }

    # GetCustomerPaymentJournalLines_CrossCompany
    resource function get CustomerPaymentJournalLines(@http:Query {name: "cross-company"} string? crossCompany) returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#CustomerPaymentJournalLines", 
            "value": [
                {
                    "dataAreaId": "USMF",
                    "JournalBatchNumber": "CustPay-001",
                    "LineNumber": 1.0,
                    "AccountType": "Cust",
                    "AccountDisplayValue": "CUST-001",
                    "CurrencyCode": "USD",
                    "AmountCurDebit": 1500.00,
                    "AmountCurCredit": 0.0,
                    "TransactionDate": "2025-07-30T00:00:00Z",
                    "Voucher": "CustPay-001",
                    "Description": "Payment from Contoso Electronics"
                }
            ]
        };
    }

    # GetCustomersV3_FieldList_CrossCompany_GBSI_USSI
    resource function get CustomersV3(@http:Query {name: "$select"} string? selectFields, @http:Query {name: "cross-company"} string? crossCompany, @http:Query {name: "$filter"} string? filter) returns json {
        json[] customers = mockCustomers.toArray();
        
        // Apply basic filtering if provided
        if filter is string {
            if filter.includes("CustomerAccount eq 'CUST-001'") {
                customers = [mockCustomers.get("CUST-001")];
            } else if filter.includes("CustomerAccount eq 'CUST-002'") {
                customers = [mockCustomers.get("CUST-002")];
            }
        }
        
        return {
            "@odata.context": "https://localhost:9090/$metadata#CustomersV3",
            "value": customers
        };
    }

    resource function get CustomersV3/\$count(@http:Query {name: "cross-company"} string? crossCompany) returns int {
        return mockCustomers.length();
    }

    # ExchangeRates_RateType_01092023
    resource function get ExchangeRates(@http:Query {name: "$filter"} string? filter) returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#ExchangeRates",
            "value": [
                {
                    "ExchangeRateType": "Default",
                    "FromCurrencyCode": "EUR",
                    "ToCurrencyCode": "USD", 
                    "StartDate": "2025-07-30T00:00:00Z",
                    "Rate": 1.1850,
                    "ExchangeRateTypeRecId": 1
                },
                {
                    "ExchangeRateType": "Default",
                    "FromCurrencyCode": "GBP", 
                    "ToCurrencyCode": "USD",
                    "StartDate": "2025-07-30T00:00:00Z",
                    "Rate": 1.2750,
                    "ExchangeRateTypeRecId": 2
                }
            ]
        };
    }

    # GetExpenseJournalHeaders_CrossCompany
    resource function get ExpenseJournalHeaders(@http:Query {name: "cross-company"} string? crossCompany) returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#ExpenseJournalHeaders",
            "value": [
                {
                    "dataAreaId": "USMF",
                    "JournalBatchNumber": "ExpJ-001",
                    "Name": "Employee Expense Journal",
                    "Description": "Monthly expense reimbursements",
                    "JournalType": "Daily",
                    "VoucherSeries": "ExpJ",
                    "PostedDateTime": "2025-07-30T14:30:00Z"
                }
            ]
        };
    }

    # GetExpenseJournalLines_CrossCompany  
    resource function get ExpenseJournalLines(@http:Query {name: "cross-company"} string? crossCompany) returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#ExpenseJournalLines",
            "value": [
                {
                    "dataAreaId": "USMF",
                    "JournalBatchNumber": "ExpJ-001",
                    "LineNumber": 1.0,
                    "AccountType": "Ledger",
                    "AccountDisplayValue": "618100--",
                    "CurrencyCode": "USD",
                    "AmountCurDebit": 250.00,
                    "AmountCurCredit": 0.0,
                    "TransactionDate": "2025-07-29T00:00:00Z",
                    "Description": "Business travel expenses"
                }
            ]
        };
    }

    # GetFinancialDimensionSets
    resource function get FinancialDimensionSets() returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#FinancialDimensionSets",
            "value": [
                {
                    "DimensionSetId": "DEFAULT",
                    "Name": "Default Dimension Set", 
                    "Description": "Standard financial dimensions",
                    "IsActive": true
                }
            ]
        };
    }

    # GetFinancialDimensionValues_RetailChannel
    resource function get FinancialDimensionValues(@http:Query {name: "$filter"} string? filter) returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#FinancialDimensionValues",
            "value": [
                {
                    "DimensionName": "BusinessUnit",
                    "DimensionValue": "001",
                    "DimensionValueDescription": "Corporate", 
                    "IsActive": true,
                    "IsSuspended": false
                },
                {
                    "DimensionName": "Department",
                    "DimensionValue": "SALES",
                    "DimensionValueDescription": "Sales Department",
                    "IsActive": true,
                    "IsSuspended": false
                }
            ]
        };
    }

    # GetFreeTextInvoiceHeaders_CrossCompany
    resource function get FreeTextInvoiceHeaders(@http:Query {name: "cross-company"} string? crossCompany) returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#FreeTextInvoiceHeaders",
            "value": [
                {
                    "dataAreaId": "USMF",
                    "InvoiceId": "FTI-001",
                    "CustomerAccount": "CUST-001",
                    "InvoiceDate": "2025-07-30T00:00:00Z",
                    "DueDate": "2025-08-29T00:00:00Z",
                    "CurrencyCode": "USD",
                    "InvoiceAmount": 1250.00,
                    "SalesTaxAmount": 125.00,
                    "TotalAmount": 1375.00
                }
            ]
        };
    }

    # GetFreeTextInvoiceLines_CrossCompany  
    resource function get FreeTextInvoiceLines(@http:Query {name: "cross-company"} string? crossCompany) returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#FreeTextInvoiceLines",
            "value": [
                {
                    "dataAreaId": "USMF",
                    "InvoiceId": "FTI-001",
                    "LineNumber": 1.0,
                    "Description": "Consulting services - July 2025",
                    "MainAccountDisplayValue": "401100-001--",
                    "Quantity": 20.0,
                    "UnitPrice": 62.50,
                    "LineAmount": 1250.00,
                    "SalesTaxGroup": "TAXABLE",
                    "ItemSalesTaxGroup": "FULL"
                }
            ]
        };
    }

    # GetCustomerInvoiceJournalHeader_CrossCompany
    resource function get GeneralLedgerCustInvoiceJournalHeaders(@http:Query {name: "cross-company"} string? crossCompany) returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#GeneralLedgerCustInvoiceJournalHeaders",
            "value": [
                {
                    "dataAreaId": "USMF",
                    "JournalBatchNumber": "CustInv-001",
                    "Name": "Customer Invoice Journal",
                    "Description": "Daily customer invoices",
                    "JournalType": "CustInvoice",
                    "PostedDateTime": "2025-07-30T16:00:00Z"
                }
            ]
        };
    }

    # GetCustomerInvoiceJournalLine_CrossCompany
    resource function get GeneralLedgerCustInvoiceJournalLines(@http:Query {name: "cross-company"} string? crossCompany) returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#GeneralLedgerCustInvoiceJournalLines",
            "value": [
                {
                    "dataAreaId": "USMF",
                    "JournalBatchNumber": "CustInv-001",
                    "LineNumber": 1.0,
                    "AccountType": "Cust",
                    "AccountDisplayValue": "CUST-001",
                    "CurrencyCode": "USD",
                    "AmountCurDebit": 0.0,
                    "AmountCurCredit": 2500.00,
                    "TransactionDate": "2025-07-30T00:00:00Z",
                    "InvoiceId": "INV-20250730-001"
                }
            ]
        };
    }

    # GetPaymentJournalLineSettledInvoices_CrossCompany
    resource function get PaymentJournalLineSettledInvoices(@http:Query {name: "cross-company"} string? crossCompany) returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#PaymentJournalLineSettledInvoices",
            "value": [
                {
                    "dataAreaId": "USMF",
                    "JournalBatchNumber": "CustPay-001",
                    "LineNumber": 1.0,
                    "InvoiceId": "INV-20250730-001",
                    "SettledAmount": 1500.00,
                    "SettlementDate": "2025-07-30T00:00:00Z"
                }
            ]
        };
    }

    # GetReleasedProducts_FieldList_CrossCompany_J00029
    resource function get ReleasedProductsV2(@http:Query {name: "$select"} string? selectFields, @http:Query {name: "cross-company"} string? crossCompany, @http:Query {name: "$filter"} string? filter) returns json {
        json[] products = mockProducts.toArray();
        
        // Apply basic filtering if provided
        if filter is string {
            if filter.includes("ItemNumber eq 'ITEM-001'") {
                products = [mockProducts.get("ITEM-001")];
            } else if filter.includes("ItemNumber eq 'ITEM-002'") {
                products = [mockProducts.get("ITEM-002")];
            }
        }
        
        return {
            "@odata.context": "https://localhost:9090/$metadata#ReleasedProductsV2",
            "value": products
        };
    }

    resource function get ReleasedProductsV2/\$count(@http:Query {name: "cross-company"} string? crossCompany) returns int {
        return mockProducts.length();
    }

    # GetSystemSecurityUserRoleAssociation
    resource function get SecurityUserRoleAssociations() returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#SecurityUserRoleAssociations",
            "value": [
                {
                    "User": "admin",
                    "SecurityRole": "SystemAdministrator",
                    "AssignmentStatus": "Enabled",
                    "AssignmentDate": "2025-07-01T00:00:00Z"
                },
                {
                    "User": "salesuser",
                    "SecurityRole": "SalesManager", 
                    "AssignmentStatus": "Enabled",
                    "AssignmentDate": "2025-07-15T00:00:00Z"
                }
            ]
        };
    }

    # GetSystemUsers
    resource function get SystemUsers() returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#SystemUsers",
            "value": [
                {
                    "UserId": "admin",
                    "UserName": "Administrator",
                    "Email": "admin@contoso.com",
                    "Enabled": true,
                    "Language": "en-US",
                    "TimeZone": "UTC",
                    "Company": "USMF"
                },
                {
                    "UserId": "salesuser",
                    "UserName": "Sales User",
                    "Email": "sales@contoso.com", 
                    "Enabled": true,
                    "Language": "en-US",
                    "TimeZone": "UTC",
                    "Company": "USMF"
                }
            ]
        };
    }

    # GetVendorGroups_CrossCompany_All
    resource function get VendorGroups(@http:Query {name: "cross-company"} string? crossCompany) returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#VendorGroups",
            "value": [
                {
                    "dataAreaId": "USMF",
                    "VendorGroupId": "10",
                    "Description": "Domestic Vendors",
                    "PaymentTermsId": "Net30",
                    "DefaultDimensionDisplayValue": "BusinessUnit--"
                },
                {
                    "dataAreaId": "USMF", 
                    "VendorGroupId": "20",
                    "Description": "International Vendors",
                    "PaymentTermsId": "Net45",
                    "DefaultDimensionDisplayValue": "BusinessUnit--"
                }
            ]
        };
    }

    resource function get VendorGroups/\$count(@http:Query {name: "cross-company"} string? crossCompany) returns int {
        return 2;
    }

    # GetVendorsV2_CrossCompany_All
    resource function get VendorsV2(@http:Query {name: "cross-company"} string? crossCompany) returns json {
        return {
            "@odata.context": "https://localhost:9090/$metadata#VendorsV2",
            "value": mockVendors.toArray()
        };
    }

    resource function get VendorsV2/\$count(@http:Query {name: "cross-company"} string? crossCompany) returns int {
        return mockVendors.length();
    }

    resource function get \$metadata() returns xml {
        return xml `<?xml version="1.0" encoding="UTF-8"?>
<edmx:Edmx xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx" Version="4.0">
    <edmx:DataServices>
        <Schema xmlns="http://docs.oasis-open.org/odata/ns/edm" Namespace="Microsoft.Dynamics.DataEntities">
            <EntityType Name="CustomersV3">
                <Key>
                    <PropertyRef Name="dataAreaId"/>
                    <PropertyRef Name="CustomerAccount"/>
                </Key>
                <Property Name="dataAreaId" Type="Edm.String" Nullable="false"/>
                <Property Name="CustomerAccount" Type="Edm.String" Nullable="false"/>
                <Property Name="CustomerName" Type="Edm.String"/>
            </EntityType>
            <EntityContainer Name="Container">
                <EntitySet Name="CustomersV3" EntityType="Microsoft.Dynamics.DataEntities.CustomersV3"/>
            </EntityContainer>
        </Schema>
    </edmx:DataServices>
</edmx:Edmx>`;
    }

    # data
    resource function get data() returns json {
        return {
            "message": "Microsoft Dynamics 365 Finance Mock Server",
            "version": "1.0.0",
            "timestamp": time:utcNow(),
            "endpoints": [
                "/CustomersV3",
                "/VendorsV2", 
                "/ReleasedProductsV2",
                "/CustomerGroups",
                "/VendorGroups",
                "/ExchangeRates",
                "/SystemUsers"
            ]
        };
    }

    # PATCH CustomersV3
    resource function patch CustomersV3/[string dataAreaId]/[string CustomerAccount](@http:Payload json payload) returns json {
        return {
            "message": "Customer updated successfully",
            "customerAccount": CustomerAccount,
            "dataAreaId": dataAreaId,
            "timestamp": time:utcNow()
        };
    }

    # PostCustomersV3
    resource function post CustomersV3(@http:Payload json payload) returns json {
        string newCustomerId = string `CUST-${uuid:createRandomUuid().substring(0, 6)}`;
        return {
            "message": "Customer created successfully",
            "customerAccount": newCustomerId,
            "timestamp": time:utcNow(),
            "data": payload
        };
    }

    resource function post DataManagementDefinitionGroups/Microsoft\.Dynamics\.DataEntities\.InitializeDataManagement() returns json {
        return {
            "message": "Data management initialized successfully",
            "timestamp": time:utcNow()
        };
    }

    # PostSystemSecurityUserRoleAssociation
    resource function post SecurityUserRoleAssociations(@http:Payload json payload) returns json {
        return {
            "message": "User role association created successfully", 
            "timestamp": time:utcNow(),
            "data": payload
        };
    }

    # PostSystemUsers
    resource function post SystemUsers(@http:Payload json payload) returns json {
        return {
            "message": "System user created successfully",
            "timestamp": time:utcNow(),
            "data": payload
        };
    }
}
