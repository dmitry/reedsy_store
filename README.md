# Technical decisions

## Architecture decisions

### Product model

The application implements model-level validations without additional database constraints. Since all interactions happen through the Rails application layer, model validations provide sufficient data consistency. This approach keeps the implementation simple while maintaining data integrity.

Code normalization is implemented at the model level by converting to uppercase. This ensures consistent code format and simplifies uniqueness validation at both application and database levels.

The price attribute is implemented as a decimal with 2 decimal points, suitable for EUR/USD currencies. For a production system with multiple currencies, the `money-rails` gem would be the preferred choice. This battle-tested solution handles various currency types effectively, including:
- Currencies with and without cents
- Cryptocurrencies
- Historical exchange rates
- Currency conversion

While database-level character limitations for code and name fields could optimize index size and improve performance, they were omitted since:
- All data manipulation occurs through the Rails application
- The current scale doesn't warrant the additional complexity
- Model validations provide sufficient control

The default integer primary key was chosen over UUID for simplicity in this demonstration. In a production environment, UUID would be preferred for:
- Better security (non-sequential IDs)
- Easier horizontal scaling
- Simplified database merging
- Prevention of ID collisions

### API Implementation

#### Security considerations

**Authentication**: The product price update endpoint (`PATCH /api/v1/products/:id/update`) would typically require authentication and admin-level authorization in a production environment. However, as per assessment requirements, authentication implementation is skipped.

**CORS**: Origin access is restricted at the Cloudflare/proxy level, with specific allowed origins configured. The application itself implements minimal CORS settings.

**Rate limiting**: Implemented through Cloudflare/HTTPS server rate limiting rules rather than application-level middleware.

**Security headers**: Implemented at proxy level:
- X-Frame-Options: DENY - Prevents iframe embedding
- X-Content-Type-Options: nosniff - Prevents MIME type sniffing
- Strict-Transport-Security: max-age=31536000 - Enforces HTTPS
- Content-Security-Policy - Controls resource loading
- X-XSS-Protection: 1; mode=block - Additional XSS protection
- Referrer-Policy: strict-origin-when-cross-origin - Controls referrer information

#### Serialization

Product serialization uses the basic `as_json` method for simplicity. Alternative approaches that could be considered for a larger application include:
- JBuilder templates
- Active Model Serializers
- Grape Entity

These alternatives would provide more structured and maintainable serialization as the API grows.

#### Error handling

The API implements centralized error handling in the BaseController to ensure consistent error responses across all endpoints:

```ruby
rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity_response
```

This approach:
- Provides uniform error responses throughout the API
- Reduces code duplication in individual controllers
- Makes error handling more maintainable
- Ensures consistent HTTP status codes (404 for not found, 422 for validation errors)

### Testing approach

The testing strategy employs fixtures for data setup. While suitable for this simple application, factory_bot would be preferred in a production environment due to:
- More flexible test data creation
- Support for complex object relationships
- Better maintainability through traits
- More intuitive test data setup

Minitest was chosen for its simplicity and Rails integration. For a production application, RSpec would be preferred because:
- Rich ecosystem of testing tools
- Better support for BDD style testing
- More expressive syntax
- Extensive matcher library
- Strong community support

## Design principles

The implementation follows these key principles:
1. Simplicity over premature optimization
2. Standard Rails conventions where possible
3. Minimal external dependencies
4. Focus on maintainability
5. Preparation for future scaling where it doesn't add significant complexity

## Preferred production stack

For a production-ready application, the following stack would be chosen:

- **Database**: PostgreSQL with UUID primary keys for scalability and better data distribution
- **Background Jobs**: Sidekiq (or good_job for single-database setups)
- **Pagination**: Pagy for its performance and simplicity
- **Authentication**: JWT tokens or HTTP-only cookies depending on the client requirements
- **API Layer**: Grape (with built-in documentation) or GraphQL for complex data relationships
- **Testing**: RSpec + factory_bot for comprehensive test coverage
- **Monitoring**: Sentry
- **Documentation**: Swagger/OpenAPI for REST or GraphiQL for GraphQL