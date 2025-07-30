_Author_: Ballerina OpenAPI Tool \
_Created_: 2025-07-30 \
_Updated_: 2025-07-30 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from microsoft.dynamics365.finance. 
The OpenAPI specification is obtained from Microsoft Dynamics 365 Finance APIs.
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

## Sanitizations Applied

1. **Added Operation IDs**: Added unique `operationId` fields to all operations for better client method generation
2. **Parameter Name Sanitization**: Added `x-ballerina-name` extensions for OData parameters to provide clean Ballerina identifiers:
   - `cross-company` → `crossCompany`
   - `$select` → `select` 
   - `$filter` → `filter`
3. **Flattened Schema Definitions**: Relocated all inline embedded schemas to the components section for improved readability
4. **Aligned for Ballerina**: Applied Ballerina-specific optimizations and conventions

# OpenAPI Specification Sanitization for Microsoft Dynamics 365 Finance

This document describes the sanitization process applied to the Microsoft Dynamics 365 Finance OpenAPI specification to generate clean Ballerina client code.

## Issues Addressed

1. **Parameter Names with Special Characters**: OData parameters like `$select`, `$filter`, and `cross-company` contained special characters that are not valid Ballerina identifiers
2. **Client Method Type**: The default client generation creates resource methods, but remote methods were needed for better API interaction

## Sanitization Process

The following transformations were applied to parameter names:
- `$select` → `selectFields` (with `x-ballerina-name` extension, avoiding reserved word `select`)
- `$filter` → `filter` (with `x-ballerina-name` extension)  
- `cross-company` → `crossCompany` (with `x-ballerina-name` extension)

The OpenAPI specification was also flattened and aligned for optimal Ballerina client generation.

## Final Client Generation Command

The following command generates the Ballerina client from the sanitized OpenAPI specification:

```bash
# Generate Ballerina client with remote methods from the final sanitized OpenAPI spec
bal openapi -i docs/spec/openapi.json --mode client --client-methods remote -o ballerina --license docs/license.txt
```

## Result

The generated client (`ballerina/client.bal`) contains:
- Remote isolated functions for all API operations
- Clean parameter names (e.g., `crossCompany` instead of `cross\-company`, `selectFields` instead of `$select`)
- Proper type definitions with valid Ballerina identifiers (avoiding reserved words)

The `openapi.json` file is the final sanitized, flattened, and aligned OpenAPI specification ready for client generation.
