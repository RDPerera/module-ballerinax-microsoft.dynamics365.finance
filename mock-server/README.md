# Microsoft Dynamics 365 Finance Mock Server

This mock server provides realistic sample data for testing the Ballerina Microsoft Dynamics 365 Finance connector without requiring an actual Dynamics 365 account.

## Quick Start

### 1. Start the Mock Server

```bash
cd mock-server
bal run
```

The server will start on `http://localhost:9090`

### 2. Test the Mock Server

Test with curl:
```bash
# Check server health
curl http://localhost:9090/health

# Get customers
curl http://localhost:9090/CustomersV3

# Get products  
curl http://localhost:9090/ReleasedProductsV2

# Get exchange rates
curl http://localhost:9090/ExchangeRates
```

### 3. Test with Your Connector

Once the mock server is running, you can test your generated Ballerina connector by pointing it to `http://localhost:9090` instead of the real Dynamics 365 endpoint.

In your connector code:
```ballerina
import ballerina/module_ballerinax_microsoft_dynamics365_finance.ballerina as d365;

public function main() returns error? {
    // Point to mock server instead of real Dynamics 365
    d365:Client client = check new("http://localhost:9090");
    
    // Test getting customers
    d365:GetCustomersV3FieldListCrossCompanyGbsiUssiQueries query = {};
    json customers = check client->getCustomersV3FieldListCrossCompanyGbsiUssi(query);
    io:println("Customers: ", customers);
}
```

## Mock Data Available

### Customers (`/CustomersV3`)
- **CUST-001**: Contoso Electronics (Credit limit: $50,000)
- **CUST-002**: Fabrikam Manufacturing (Credit limit: $75,000)

### Products (`/ReleasedProductsV2`)
- **ITEM-001**: Surface Pro Tablet ($999.99)
- **ITEM-002**: Wireless Mouse ($29.99)

### Vendors (`/VendorsV2`)
- **VEND-001**: Alpine Ski House
- **VEND-002**: City Power & Light

### Exchange Rates (`/ExchangeRates`)
- EUR/USD: 1.1850
- GBP/USD: 1.2750

## API Endpoints

### Core Data
- `GET /CustomersV3` - Get customers
- `GET /CustomersV3/$count` - Get customer count
- `POST /CustomersV3` - Create customer
- `GET /VendorsV2` - Get vendors
- `GET /ReleasedProductsV2` - Get products
- `GET /CustomerGroups` - Get customer groups
- `GET /VendorGroups` - Get vendor groups
- `GET /ExchangeRates` - Get exchange rates
- `GET /SystemUsers` - Get system users

### Query Parameters
- `$filter` - Filter results (basic support)
- `$select` - Select specific fields
- `cross-company` - Cross-company queries

### OData Standard
- `GET /$metadata` - OData metadata
- `GET /health` - Server health check
- `GET /data` - Server information

## Sample Responses

### Customer Response
```json
{
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
    }
  ]
}
```

## Benefits for Testing

✅ **No Authentication Required** - No need for Dynamics 365 credentials  
✅ **Realistic Data** - Pre-populated with business-realistic sample data  
✅ **Fast Response** - Instant responses for rapid development  
✅ **OData Compliant** - Follows OData standards like real Dynamics 365  
✅ **Cross-Company Support** - Mock cross-company data access  
✅ **Complete CRUD** - Support for GET, POST, PATCH operations  

## Troubleshooting

### Server Won't Start
- Check if port 9090 is available: `lsof -i :9090`
- Verify Ballerina installation: `bal version`
- Make sure you're in the mock-server directory: `pwd`

### Connection Refused
- Ensure server is running: `curl http://localhost:9090/health`
- Check firewall settings
- Try using 127.0.0.1 instead of localhost

### No Data Returned
- Check endpoint URLs are correct (case-sensitive)
- Verify the server started without compilation errors
- Check server logs for any error messages

## Next Steps

1. **Generate Your Client**: Use the main OpenAPI spec to generate your Ballerina client
2. **Point to Mock Server**: Change the base URL to `http://localhost:9090`
3. **Run Tests**: Test all your connector functionality with realistic data
4. **Develop Offline**: No internet connection needed for development
5. **Switch to Production**: Change base URL back to real Dynamics 365 when ready

This mock server lets you develop and test your Dynamics 365 Finance connector completely offline! 🎉
