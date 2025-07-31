from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime, timezone
from dateutil.relativedelta import relativedelta
import uuid
import json

app = Flask(__name__)
CORS(app)

# In-memory data stores
vendors = {}
customers = {}
system_users = {}

# Helper function to generate OData response format
def odata_response(data, count=None, context_url=None):
    response = {
        "@odata.context": context_url or "https://your-org.cloud.onebox.dynamics.com/data/$metadata",
        "value": data
    }
    if count is not None:
        response["@odata.count"] = count
    return response

# Helper function to generate etag
def generate_etag():
    return f'W/"{str(uuid.uuid4())}"'

# Helper function to get current ISO datetime
def get_current_datetime():
    return datetime.now(timezone.utc).isoformat()

# Vendor endpoints
@app.route('/VendorsV2', methods=['GET'])
def get_vendors():
    """Get all vendors"""
    vendor_list = list(vendors.values())
    
    # Handle OData query parameters
    skip = request.args.get('$skip', type=int, default=0)
    top = request.args.get('$top', type=int, default=len(vendor_list))
    filter_query = request.args.get('$filter', '')
    select_fields = request.args.get('$select', '')
    
    # Apply pagination
    paginated_vendors = vendor_list[skip:skip + top]
    
    # Apply field selection if specified
    if select_fields:
        fields = [field.strip() for field in select_fields.split(',')]
        filtered_vendors = []
        for vendor in paginated_vendors:
            filtered_vendor = {field: vendor.get(field) for field in fields if field in vendor}
            filtered_vendor['@odata.etag'] = vendor.get('@odata.etag')
            filtered_vendors.append(filtered_vendor)
        paginated_vendors = filtered_vendors
    
    return jsonify(odata_response(
        paginated_vendors, 
        count=len(vendor_list),
        context_url="https://your-org.cloud.onebox.dynamics.com/data/$metadata#VendorsV2"
    ))

@app.route('/VendorsV2', methods=['POST'])
def create_vendor():
    """Create a new vendor"""
    data = request.get_json()
    
    # Generate vendor account if not provided
    if 'VendorAccount' not in data or not data['VendorAccount']:
        data['VendorAccount'] = f"V{len(vendors) + 1:06d}"
    
    # Set default values
    vendor = {
        "@odata.etag": generate_etag(),
        "dataAreaId": data.get("dataAreaId", "USMF"),
        "VendorAccount": data["VendorAccount"],
        "OrganizationName": data.get("OrganizationName", ""),
        "VendorGroupId": data.get("VendorGroupId", "10"),
        "AddressCountryRegionId": data.get("AddressCountryRegionId", "US"),
        "PurchaseCurrencyCode": data.get("PurchaseCurrencyCode", "USD"),
        "IsActive": data.get("IsActive", True)
    }
    
    # Store vendor
    vendor_key = f"{vendor['dataAreaId']}_{vendor['VendorAccount']}"
    vendors[vendor_key] = vendor
    
    return jsonify(vendor), 201

@app.route('/VendorsV2/$count', methods=['GET'])
def get_vendors_count():
    """Get count of vendors"""
    return str(len(vendors))

# Customer endpoints
@app.route('/CustomersV3', methods=['GET'])
def get_customers():
    """Get all customers"""
    customer_list = list(customers.values())
    
    # Handle OData query parameters
    skip = request.args.get('$skip', type=int, default=0)
    top = request.args.get('$top', type=int, default=len(customer_list))
    filter_query = request.args.get('$filter', '')
    orderby = request.args.get('$orderby', '')
    select_fields = request.args.get('$select', '')
    
    # Apply pagination
    paginated_customers = customer_list[skip:skip + top]
    
    # Apply field selection if specified
    if select_fields:
        fields = [field.strip() for field in select_fields.split(',')]
        filtered_customers = []
        for customer in paginated_customers:
            filtered_customer = {field: customer.get(field) for field in fields if field in customer}
            filtered_customer['@odata.etag'] = customer.get('@odata.etag')
            filtered_customers.append(filtered_customer)
        paginated_customers = filtered_customers
    
    return jsonify(odata_response(
        paginated_customers, 
        count=len(customer_list),
        context_url="https://your-org.cloud.onebox.dynamics.com/data/$metadata#CustomersV3"
    ))

@app.route('/CustomersV3', methods=['POST'])
def create_customer():
    """Create a new customer"""
    data = request.get_json()
    
    # Generate customer account if not provided
    if 'CustomerAccount' not in data or not data['CustomerAccount']:
        data['CustomerAccount'] = f"C{len(customers) + 1:06d}"
    
    # Set default values
    customer = {
        "@odata.etag": generate_etag(),
        "dataAreaId": data.get("dataAreaId", "USMF"),
        "CustomerAccount": data["CustomerAccount"],
        "OrganizationName": data.get("OrganizationName", ""),
        "NameAlias": data.get("NameAlias", ""),
        "CustomerGroupId": data.get("CustomerGroupId", "10"),
        "AddressCountryRegionId": data.get("AddressCountryRegionId", "US"),
        "SalesCurrencyCode": data.get("SalesCurrencyCode", "USD"),
        "PersonGender": data.get("PersonGender", "Unknown"),
        "CreditLimit": data.get("CreditLimit", 0.0),
        "IsActive": data.get("IsActive", True)
    }
    
    # Store customer
    customer_key = f"{customer['dataAreaId']}_{customer['CustomerAccount']}"
    customers[customer_key] = customer
    
    return jsonify(customer), 201

@app.route("/CustomersV3(dataAreaId='<data_area_id>',CustomerAccount='<customer_account>')", methods=['PATCH'])
def update_customer(data_area_id, customer_account):
    """Update an existing customer"""
    customer_key = f"{data_area_id}_{customer_account}"
    
    if customer_key not in customers:
        return jsonify({"error": "Customer not found"}), 404
    
    data = request.get_json()
    customer = customers[customer_key].copy()
    
    # Update fields from request
    for field, value in data.items():
        if field != "@odata.etag":
            customer[field] = value
    
    # Update etag
    customer["@odata.etag"] = generate_etag()
    
    # Store updated customer
    customers[customer_key] = customer
    
    return jsonify(customer)

@app.route('/CustomersV3/$count', methods=['GET'])
def get_customers_count():
    """Get count of customers"""
    return str(len(customers))

# Exchange Rate endpoints
@app.route('/ExchangeRates', methods=['GET'])
def get_exchange_rates():
    """Get exchange rates"""
    # Sample exchange rates data
    exchange_rates = [
        {
            "@odata.etag": generate_etag(),
            "FromCurrencyCode": "USD",
            "ToCurrencyCode": "EUR",
            "ExchangeRateValue": 0.85,
            "ValidFromDate": "2025-01-01T00:00:00Z",
            "RateTypeId": "SPOT"
        },
        {
            "@odata.etag": generate_etag(),
            "FromCurrencyCode": "USD",
            "ToCurrencyCode": "GBP",
            "ExchangeRateValue": 0.75,
            "ValidFromDate": "2025-01-01T00:00:00Z",
            "RateTypeId": "SPOT"
        },
        {
            "@odata.etag": generate_etag(),
            "FromCurrencyCode": "EUR",
            "ToCurrencyCode": "USD",
            "ExchangeRateValue": 1.18,
            "ValidFromDate": "2025-01-01T00:00:00Z",
            "RateTypeId": "SPOT"
        },
        {
            "@odata.etag": generate_etag(),
            "FromCurrencyCode": "GBP",
            "ToCurrencyCode": "USD",
            "ExchangeRateValue": 1.33,
            "ValidFromDate": "2025-01-01T00:00:00Z",
            "RateTypeId": "SPOT"
        }
    ]
    
    # Handle filter parameter
    filter_query = request.args.get('$filter', '')
    
    return jsonify(odata_response(
        exchange_rates,
        count=len(exchange_rates),
        context_url="https://your-org.cloud.onebox.dynamics.com/data/$metadata#ExchangeRates"
    ))

# System User endpoints
@app.route('/SystemUsers', methods=['GET'])
def get_system_users():
    """Get all system users"""
    user_list = list(system_users.values())
    
    return jsonify(odata_response(
        user_list,
        count=len(user_list),
        context_url="https://your-org.cloud.onebox.dynamics.com/data/$metadata#SystemUsers"
    ))

@app.route('/SystemUsers', methods=['POST'])
def create_system_user():
    """Create a new system user"""
    data = request.get_json()
    
    # Generate user ID if not provided
    if 'UserId' not in data or not data['UserId']:
        data['UserId'] = f"USER{len(system_users) + 1:04d}"
    
    # Set default values
    user = {
        "@odata.etag": generate_etag(),
        "UserId": data["UserId"],
        "UserName": data.get("UserName", data["UserId"]),
        "Email": data.get("Email", f"{data['UserId'].lower()}@company.com"),
        "IsActive": data.get("IsActive", True)
    }
    
    # Store user
    system_users[user["UserId"]] = user
    
    return jsonify(user), 201

# OData service root
@app.route('/data', methods=['GET'])
def get_service_root():
    """Get OData service root"""
    service_root = {
        "@odata.context": "https://your-org.cloud.onebox.dynamics.com/data/$metadata",
        "value": [
            {"name": "VendorsV2", "kind": "EntitySet", "url": "VendorsV2"},
            {"name": "CustomersV3", "kind": "EntitySet", "url": "CustomersV3"},
            {"name": "ExchangeRates", "kind": "EntitySet", "url": "ExchangeRates"},
            {"name": "SystemUsers", "kind": "EntitySet", "url": "SystemUsers"},
            {"name": "ReleasedProductsV2", "kind": "EntitySet", "url": "ReleasedProductsV2"},
            {"name": "CustomerGroups", "kind": "EntitySet", "url": "CustomerGroups"}
        ]
    }
    
    return jsonify(service_root)

# OData metadata
@app.route('/$metadata', methods=['GET'])
def get_metadata():
    """Get OData metadata"""
    metadata = '''<?xml version="1.0" encoding="UTF-8"?>
<edmx:Edmx xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx" Version="4.0">
  <edmx:DataServices>
    <Schema xmlns="http://docs.oasis-open.org/odata/ns/edm" Namespace="Microsoft.Dynamics365.Finance">
      <EntityContainer Name="Container">
        <EntitySet Name="VendorsV2" EntityType="Microsoft.Dynamics365.Finance.VendorV2"/>
        <EntitySet Name="CustomersV3" EntityType="Microsoft.Dynamics365.Finance.CustomerV3"/>
        <EntitySet Name="ExchangeRates" EntityType="Microsoft.Dynamics365.Finance.ExchangeRate"/>
        <EntitySet Name="SystemUsers" EntityType="Microsoft.Dynamics365.Finance.SystemUser"/>
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>'''
    
    return metadata, 200, {'Content-Type': 'application/xml'}

# Health check endpoint
@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "timestamp": get_current_datetime(),
        "version": "1.0.0",
        "endpoints": {
            "vendors": len(vendors),
            "customers": len(customers),
            "system_users": len(system_users)
        }
    })

# Initialize with some sample data
def initialize_sample_data():
    """Initialize the mock server with sample data"""
    
    # Sample vendors
    sample_vendors = [
        {
            "dataAreaId": "USMF",
            "VendorAccount": "V000001",
            "OrganizationName": "Contoso Electronics",
            "VendorGroupId": "10",
            "AddressCountryRegionId": "US",
            "PurchaseCurrencyCode": "USD",
            "IsActive": True
        },
        {
            "dataAreaId": "USMF",
            "VendorAccount": "V000002",
            "OrganizationName": "Fabrikam Supplies",
            "VendorGroupId": "20",
            "AddressCountryRegionId": "US",
            "PurchaseCurrencyCode": "USD",
            "IsActive": True
        }
    ]
    
    for vendor_data in sample_vendors:
        vendor = vendor_data.copy()
        vendor["@odata.etag"] = generate_etag()
        vendor_key = f"{vendor['dataAreaId']}_{vendor['VendorAccount']}"
        vendors[vendor_key] = vendor
    
    # Sample customers
    sample_customers = [
        {
            "dataAreaId": "USMF",
            "CustomerAccount": "C000001",
            "OrganizationName": "Adventure Works",
            "NameAlias": "AWorks",
            "CustomerGroupId": "10",
            "AddressCountryRegionId": "US",
            "SalesCurrencyCode": "USD",
            "PersonGender": "Unknown",
            "CreditLimit": 50000.0,
            "IsActive": True
        },
        {
            "dataAreaId": "USMF",
            "CustomerAccount": "C000002",
            "OrganizationName": "Blue Yonder Airlines",
            "NameAlias": "BlueYonder",
            "CustomerGroupId": "20",
            "AddressCountryRegionId": "US",
            "SalesCurrencyCode": "USD",
            "PersonGender": "Unknown",
            "CreditLimit": 100000.0,
            "IsActive": True
        }
    ]
    
    for customer_data in sample_customers:
        customer = customer_data.copy()
        customer["@odata.etag"] = generate_etag()
        customer_key = f"{customer['dataAreaId']}_{customer['CustomerAccount']}"
        customers[customer_key] = customer
    
    # Sample system users
    sample_users = [
        {
            "UserId": "ADMIN",
            "UserName": "admin",
            "Email": "admin@company.com",
            "IsActive": True
        },
        {
            "UserId": "USER001",
            "UserName": "testuser",
            "Email": "testuser@company.com",
            "IsActive": True
        }
    ]
    
    for user_data in sample_users:
        user = user_data.copy()
        user["@odata.etag"] = generate_etag()
        system_users[user["UserId"]] = user

if __name__ == '__main__':
    initialize_sample_data()
    print("Microsoft Dynamics 365 Finance Mock Server")
    print("==========================================")
    print("Available endpoints:")
    print("  GET    /VendorsV2                 - Get all vendors")
    print("  POST   /VendorsV2                 - Create vendor")
    print("  GET    /VendorsV2/$count          - Get vendor count")
    print("  GET    /CustomersV3               - Get all customers")
    print("  POST   /CustomersV3               - Create customer")
    print("  PATCH  /CustomersV3(...)          - Update customer")
    print("  GET    /CustomersV3/$count        - Get customer count")
    print("  GET    /ExchangeRates             - Get exchange rates")
    print("  GET    /SystemUsers               - Get system users")
    print("  POST   /SystemUsers               - Create system user")
    print("  GET    /data                      - OData service root")
    print("  GET    /$metadata                 - OData metadata")
    print("  GET    /health                    - Health check")
    print("==========================================")
    print("Server starting on http://localhost:8080")
    app.run(debug=True, host='0.0.0.0', port=8080)
