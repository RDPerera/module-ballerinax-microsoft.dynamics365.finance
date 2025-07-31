# Quick Start Guide

## Microsoft Dynamics 365 Finance Mock Server

### 🚀 Quick Setup & Run

```bash
cd mockserver
./start.sh
```

That's it! The server will be running at `http://localhost:8080`

### 📋 What You Get

**API Endpoints for your integration:**
- `POST /VendorsV2` - Create vendor
- `GET /VendorsV2` - Get vendors  
- `POST /CustomersV3` - Create customer
- `GET /CustomersV3` - Get customers
- `PATCH /CustomersV3(dataAreaId='...',CustomerAccount='...')` - Update customer
- `GET /ExchangeRates` - Get exchange rates
- `POST /SystemUsers` - Create system user
- `GET /SystemUsers` - Get system users

### 🧪 Test It

```bash
# Health check
curl http://localhost:8080/health

# Get vendors
curl http://localhost:8080/VendorsV2

# Create a vendor
curl -X POST http://localhost:8080/VendorsV2 \
  -H "Content-Type: application/json" \
  -d '{"OrganizationName": "Test Vendor", "VendorGroupId": "10"}'
```

### 🔧 Use with Ballerina Client

```ballerina
Client client = check new({
    auth: {
        token: "any-token"  // Mock server accepts any token
    }
}, serviceUrl = "http://localhost:8080");
```

### 📊 Sample Data Included

- 2 vendors (Contoso Electronics, Fabrikam Supplies)
- 2 customers (Adventure Works, Blue Yonder Airlines)
- 2 system users (Admin, Test User)
- Exchange rates (USD/EUR, USD/GBP, etc.)

### 🎯 Available Commands

```bash
./start.sh          # Start server (default)
./start.sh setup    # Setup environment only
./start.sh test     # Run tests
./start.sh help     # Show help
```

Ready to test your Dynamics 365 Finance integrations! 🎉
