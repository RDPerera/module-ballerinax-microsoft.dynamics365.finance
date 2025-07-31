# Microsoft Dynamics 365 Finance Mock Server

This is a Python Flask-based mock server that simulates the Microsoft Dynamics 365 Finance and Operations OData REST API. It provides realistic mock responses for testing and development purposes.

## Features

The mock server implements the following endpoints based on your integration requirements:

### Vendor Management
- **POST /VendorsV2** - Create a new vendor
- **GET /VendorsV2** - Get all vendors with OData query support
- **GET /VendorsV2/$count** - Get vendor count

### Customer Management
- **POST /CustomersV3** - Create a new customer
- **GET /CustomersV3** - Get all customers with OData query support
- **PATCH /CustomersV3(dataAreaId='...',CustomerAccount='...')** - Update existing customer
- **GET /CustomersV3/$count** - Get customer count

### Exchange Rates
- **GET /ExchangeRates** - Get exchange rates with sample USD, EUR, GBP rates

### System Users
- **POST /SystemUsers** - Create a new system user
- **GET /SystemUsers** - Get all system users

### OData Service
- **GET /data** - OData service root
- **GET /$metadata** - OData metadata document

### Health Check
- **GET /health** - Server health and statistics

## Setup Instructions

### Prerequisites
- Python 3.7 or higher
- pip (Python package installer)

### Installation

1. **Navigate to the mockserver directory:**
   ```bash
   cd mockserver
   ```

2. **Use the startup script (recommended):**
   ```bash
   ./start.sh
   ```
   
   Or manually:

3. **Create a virtual environment (recommended):**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

4. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

### Running the Server

1. **Start the mock server:**
   ```bash
   python mock_server.py
   ```

2. **Server will start on http://localhost:8080**

3. **Test the server:**
   ```bash
   curl http://localhost:8080/health
   ```

## Usage Examples

### Create a Vendor
```bash
curl -X POST http://localhost:8080/VendorsV2 \
  -H "Content-Type: application/json" \
  -d '{
    "dataAreaId": "USMF",
    "OrganizationName": "New Supplier Inc",
    "VendorGroupId": "10",
    "AddressCountryRegionId": "US",
    "PurchaseCurrencyCode": "USD"
  }'
```

### Get All Vendors
```bash
curl "http://localhost:8080/VendorsV2"
```

### Get Vendors with OData Query Parameters
```bash
# Get top 5 vendors
curl "http://localhost:8080/VendorsV2?\$top=5"

# Select specific fields
curl "http://localhost:8080/VendorsV2?\$select=VendorAccount,OrganizationName"

# Skip first 2 vendors and get next 3
curl "http://localhost:8080/VendorsV2?\$skip=2&\$top=3"
```

### Create a Customer
```bash
curl -X POST http://localhost:8080/CustomersV3 \
  -H "Content-Type: application/json" \
  -d '{
    "dataAreaId": "USMF",
    "OrganizationName": "New Customer Corp",
    "CustomerGroupId": "10",
    "AddressCountryRegionId": "US",
    "SalesCurrencyCode": "USD",
    "CreditLimit": 25000.0
  }'
```

### Update a Customer
```bash
curl -X PATCH "http://localhost:8080/CustomersV3(dataAreaId='USMF',CustomerAccount='C000001')" \
  -H "Content-Type: application/json" \
  -d '{
    "OrganizationName": "Updated Customer Name",
    "CreditLimit": 75000.0
  }'
```

### Get Exchange Rates
```bash
curl "http://localhost:8080/ExchangeRates"
```

### Create a System User
```bash
curl -X POST http://localhost:8080/SystemUsers \
  -H "Content-Type: application/json" \
  -d '{
    "UserName": "newuser",
    "Email": "newuser@company.com",
    "IsActive": true
  }'
```

### Get System Users
```bash
curl "http://localhost:8080/SystemUsers"
```

## Sample Data

The mock server initializes with sample data including:

### Vendors
- **V000001** - Contoso Electronics
- **V000002** - Fabrikam Supplies

### Customers
- **C000001** - Adventure Works
- **C000002** - Blue Yonder Airlines

### System Users
- **ADMIN** - admin user
- **USER001** - test user

### Exchange Rates
- USD/EUR: 0.85
- USD/GBP: 0.75
- EUR/USD: 1.18
- GBP/USD: 1.33

## OData Query Parameters Supported

The mock server supports common OData query parameters:

- **$top** - Limit number of results
- **$skip** - Skip number of results (pagination)
- **$select** - Select specific fields
- **$filter** - Filter results (basic support)
- **$orderby** - Order results (basic support)
- **$count** - Include count in response

## Response Format

All responses follow the OData v4 format:

```json
{
  "@odata.context": "https://your-org.cloud.onebox.dynamics.com/data/$metadata#VendorsV2",
  "@odata.count": 2,
  "value": [
    {
      "@odata.etag": "W/\"uuid-string\"",
      "dataAreaId": "USMF",
      "VendorAccount": "V000001",
      "OrganizationName": "Contoso Electronics",
      "VendorGroupId": "10",
      "AddressCountryRegionId": "US",
      "PurchaseCurrencyCode": "USD",
      "IsActive": true
    }
  ]
}
```

## Configuration

The server runs on `localhost:5000` by default. You can modify the host and port in the `mock_server.py` file:

```python
app.run(debug=True, host='0.0.0.0', port=5000)
```

## Integration with Ballerina Client

To use this mock server with your Ballerina client, update the service URL:

```ballerina
Client client = check new({
    auth: {
        token: "your-token"
    }
}, serviceUrl = "http://localhost:8080");
```

## Troubleshooting

1. **Port already in use**: The server now uses port 8080 to avoid conflicts with macOS AirPlay Receiver (port 5000)
2. **Import errors**: Make sure all dependencies are installed: `pip install -r requirements.txt`
3. **CORS issues**: The server includes CORS support, but you may need to adjust headers for your specific use case

## Development

To extend the mock server:

1. Add new endpoints in `mock_server.py`
2. Update the data models as needed
3. Add appropriate OData query parameter support
4. Update this README with new endpoint documentation

The mock server is designed to be easily extensible and can be modified to support additional Dynamics 365 Finance entities and operations as needed.
