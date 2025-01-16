# Technical Decisions

## Architecture Decisions

### Product Model

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

Product serialization uses the basic `as_json` method for simplicity. Alternative approaches that could be considered for a larger application include:
- JBuilder templates
- Active Model Serializers
- Grape Entity - preferred

These alternatives would provide more structured and maintainable serialization as the API grows.

### Testing Approach

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

## Design Principles

The implementation follows these key principles:
1. Simplicity over premature optimization
2. Standard Rails conventions where possible
3. Minimal external dependencies
4. Focus on maintainability
5. Preparation for future scaling where it doesn't add significant complexity

## Preferred Production Stack

For a production-ready application, the following stack would be chosen:

- **Database**: PostgreSQL with UUID primary keys for scalability and better data distribution
- **Background Jobs**: Sidekiq (or good_job for single-database setups)
- **Pagination**: Pagy for its performance and simplicity
- **Authentication**: JWT tokens or HTTP-only cookies depending on the client requirements
- **API Layer**: Grape (with built-in documentation) or GraphQL for complex data relationships
- **Testing**: RSpec + factory_bot for comprehensive test coverage
- **Monitoring**: Sentry
- **Documentation**: Swagger/OpenAPI for REST or GraphiQL for GraphQL