#!/usr/bin/env python3
"""
Test script for Microsoft Dynamics 365 Finance Mock Server
This script tests all the main endpoints and functionality.
"""

import requests
import json
import time
import sys

BASE_URL = "http://localhost:8080"

def test_health():
    """Test health endpoint"""
    print("Testing health endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        print("✅ Health check passed")
        return True
    except Exception as e:
        print(f"❌ Health check failed: {e}")
        return False

def test_service_root():
    """Test OData service root"""
    print("Testing service root...")
    try:
        response = requests.get(f"{BASE_URL}/data")
        assert response.status_code == 200
        data = response.json()
        assert "value" in data
        assert len(data["value"]) > 0
        print("✅ Service root test passed")
        return True
    except Exception as e:
        print(f"❌ Service root test failed: {e}")
        return False

def test_vendors():
    """Test vendor endpoints"""
    print("Testing vendor endpoints...")
    try:
        # Test GET vendors
        response = requests.get(f"{BASE_URL}/VendorsV2")
        assert response.status_code == 200
        data = response.json()
        assert "value" in data
        initial_count = len(data["value"])
        
        # Test CREATE vendor
        new_vendor = {
            "dataAreaId": "USMF",
            "OrganizationName": "Test Vendor Corp",
            "VendorGroupId": "10",
            "AddressCountryRegionId": "US",
            "PurchaseCurrencyCode": "USD"
        }
        response = requests.post(f"{BASE_URL}/VendorsV2", json=new_vendor)
        assert response.status_code == 201
        created_vendor = response.json()
        assert created_vendor["OrganizationName"] == "Test Vendor Corp"
        assert "VendorAccount" in created_vendor
        
        # Test GET vendors count
        response = requests.get(f"{BASE_URL}/VendorsV2/$count")
        assert response.status_code == 200
        count = int(response.text)
        assert count == initial_count + 1
        
        # Test GET with OData parameters
        response = requests.get(f"{BASE_URL}/VendorsV2?$top=1&$select=VendorAccount,OrganizationName")
        assert response.status_code == 200
        data = response.json()
        assert len(data["value"]) <= 1
        
        print("✅ Vendor tests passed")
        return True
    except Exception as e:
        print(f"❌ Vendor tests failed: {e}")
        return False

def test_customers():
    """Test customer endpoints"""
    print("Testing customer endpoints...")
    try:
        # Test GET customers
        response = requests.get(f"{BASE_URL}/CustomersV3")
        assert response.status_code == 200
        data = response.json()
        assert "value" in data
        initial_count = len(data["value"])
        
        # Test CREATE customer
        new_customer = {
            "dataAreaId": "USMF",
            "OrganizationName": "Test Customer Inc",
            "CustomerGroupId": "10",
            "AddressCountryRegionId": "US",
            "SalesCurrencyCode": "USD",
            "CreditLimit": 15000.0
        }
        response = requests.post(f"{BASE_URL}/CustomersV3", json=new_customer)
        assert response.status_code == 201
        created_customer = response.json()
        assert created_customer["OrganizationName"] == "Test Customer Inc"
        customer_account = created_customer["CustomerAccount"]
        
        # Test UPDATE customer
        update_data = {
            "OrganizationName": "Updated Test Customer Inc",
            "CreditLimit": 25000.0
        }
        update_url = f"{BASE_URL}/CustomersV3(dataAreaId='USMF',CustomerAccount='{customer_account}')"
        response = requests.patch(update_url, json=update_data)
        assert response.status_code == 200
        updated_customer = response.json()
        assert updated_customer["OrganizationName"] == "Updated Test Customer Inc"
        assert updated_customer["CreditLimit"] == 25000.0
        
        # Test GET customers count
        response = requests.get(f"{BASE_URL}/CustomersV3/$count")
        assert response.status_code == 200
        count = int(response.text)
        assert count == initial_count + 1
        
        print("✅ Customer tests passed")
        return True
    except Exception as e:
        print(f"❌ Customer tests failed: {e}")
        return False

def test_exchange_rates():
    """Test exchange rates endpoint"""
    print("Testing exchange rates...")
    try:
        response = requests.get(f"{BASE_URL}/ExchangeRates")
        assert response.status_code == 200
        data = response.json()
        assert "value" in data
        assert len(data["value"]) > 0
        
        # Check if we have expected currency pairs
        rates = data["value"]
        currency_pairs = [(rate["FromCurrencyCode"], rate["ToCurrencyCode"]) for rate in rates]
        assert ("USD", "EUR") in currency_pairs
        assert ("USD", "GBP") in currency_pairs
        
        print("✅ Exchange rates test passed")
        return True
    except Exception as e:
        print(f"❌ Exchange rates test failed: {e}")
        return False

def test_system_users():
    """Test system users endpoints"""
    print("Testing system users...")
    try:
        # Test GET system users
        response = requests.get(f"{BASE_URL}/SystemUsers")
        assert response.status_code == 200
        data = response.json()
        assert "value" in data
        initial_count = len(data["value"])
        
        # Test CREATE system user
        new_user = {
            "UserName": "testuser123",
            "Email": "testuser123@company.com",
            "IsActive": True
        }
        response = requests.post(f"{BASE_URL}/SystemUsers", json=new_user)
        assert response.status_code == 201
        created_user = response.json()
        assert created_user["UserName"] == "testuser123"
        assert "UserId" in created_user
        
        # Verify user was added
        response = requests.get(f"{BASE_URL}/SystemUsers")
        assert response.status_code == 200
        data = response.json()
        assert len(data["value"]) == initial_count + 1
        
        print("✅ System users tests passed")
        return True
    except Exception as e:
        print(f"❌ System users tests failed: {e}")
        return False

def test_metadata():
    """Test OData metadata endpoint"""
    print("Testing metadata endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/$metadata")
        assert response.status_code == 200
        assert response.headers.get("Content-Type") == "application/xml"
        assert "EntityContainer" in response.text
        print("✅ Metadata test passed")
        return True
    except Exception as e:
        print(f"❌ Metadata test failed: {e}")
        return False

def run_all_tests():
    """Run all tests"""
    print("🚀 Starting Microsoft Dynamics 365 Finance Mock Server Tests")
    print("=" * 60)
    
    # Wait a moment for server to be ready
    print("Waiting for server to be ready...")
    time.sleep(2)
    
    tests = [
        test_health,
        test_service_root,
        test_metadata,
        test_vendors,
        test_customers,
        test_exchange_rates,
        test_system_users
    ]
    
    passed = 0
    failed = 0
    
    for test in tests:
        try:
            if test():
                passed += 1
            else:
                failed += 1
        except Exception as e:
            print(f"❌ Test {test.__name__} failed with exception: {e}")
            failed += 1
        print()
    
    print("=" * 60)
    print(f"Test Results: {passed} passed, {failed} failed")
    
    if failed == 0:
        print("🎉 All tests passed!")
        return 0
    else:
        print("💥 Some tests failed!")
        return 1

if __name__ == "__main__":
    exit_code = run_all_tests()
    sys.exit(exit_code)
