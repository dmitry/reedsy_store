# Reedsy Store

Demo: https://reedsy-store.fly.dev/api/v1/products.json

## Setup Instructions

### Requirements
- Ruby 3.4+
- SQLite3

### Installation

```bash
git clone git@github.com:dmitry/reedsy_store.git
cd reedsy_store
bundle install
rails db:setup
```

### Running Tests

```bash
rails test
```

### Local Development Workflow

1. Start the server: `rails s`
2. Access local API: `open http://localhost:3000`
3. View logs: `tail -f log/development.log`

### Deployment

The application is currently deployed on Fly.io. Deployment steps:

```
curl -L https://fly.io/install.sh | sh
fly deploy
```

## API Documentation

### Endpoints

#### GET /api/v1/products
Returns list of all products.

```bash
curl -X GET http://localhost:3000/api/v1/products
```

#### PATCH /api/v1/products/:id
Updates product price.

```bash
curl -X PATCH http://localhost:3000/api/v1/products/1 \
  -H "Content-Type: application/json" \
  -d '{"product":{"price":"7.50"}}'
```

#### POST /api/v1/products/calculate
Calculates total price with discounts.

```bash
curl -X POST http://localhost:3000/api/v1/products/calculate \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"id": 1, "quantity": 2},
      {"id": 2, "quantity": 3}
    ]
  }'
```

## Technical Design

### Architecture Decisions

#### Product Model
The application implements model-level validations without additional database constraints. Since all interactions happen through the Rails application layer, model validations provide sufficient data consistency. This approach keeps the implementation simple while maintaining data integrity.

Code normalization is implemented at the model level by converting to uppercase. This ensures consistent code format and simplifies uniqueness validation at both application and database levels.

The price attribute is implemented as a decimal with 2 decimal points, suitable for EUR/USD currencies. For a production system with multiple currencies, the `money-rails` gem would be the preferred choice. This battle-tested solution handles various currency types effectively:
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

#### Product Price Calculation
The application uses ActiveModel extensively to handle complex calculations and validations outside of ActiveRecord models. Here's how and why:

##### Calculation Logic with ActiveModel
The calculation logic is implemented using two main classes:
- `Product::Calculation` - Handles the overall price calculation for a cart
- `Product::CalculationItem` - Represents individual items in the calculation

This separation using ActiveModel provides several benefits:
1. Keeps business logic separate from persistence models
2. Enables complex validations without database overhead
3. Provides a clean interface for the API layer
4. Makes the code more testable with clear responsibilities

The ActiveModel implementation was designed to be extensible for future needs:
- Easy and flexible to add new discount types
- Simple to add new validation contexts
- Ready for potential persistence if needed

## API Structure

### Namespace Organization
The API uses versioned namespaces to ensure backward compatibility and clean upgrade paths:

- `Api::BaseController`: Common functionality for all API versions
  - Centralized error handling
  - Common response formats
  - Shared authentication (when implemented)

- `Api::V1`: First version of the API
  - Isolated from future versions
  - Own set of serializers and validations
  - Can be deprecated while maintaining support
  - It might be good to add `Api::V1::BaseController`

### Error Handling

#### Response Format
All error responses follow a consistent structure:

```json
{
  "errors": {
    "field_name": ["error message"],
    "base": ["error message"]
  }
}
```

#### HTTP Status Codes
- `400 Bad Request`: Malformed request syntax
- `404 Not Found`: Resource not found
- `422 Unprocessable Entity`: Validation errors
- `500 Internal Server Error`: Server-side errors

#### Validation Error Examples

Product not found:
```json
{
  "error": "Couldn't find Product with id=0"
}
```

Invalid price update:
```json
{
  "errors": {
    "price": ["must be greater than 0"]
  }
}
```

Invalid calculation request (with indexes):
```json
{
  "errors": {
    "base": ["Products must be unique"],
    "items[0].quantity": ["must be greater than 0"],
    "items[1].product": ["can't be blank"]
  }
}
```

#### Security Considerations
The API implements several security measures at different levels:

- **Authentication**: The product price update endpoint would typically require authentication and admin-level authorization in a production environment. However, as per requirements, authentication implementation is skipped.

- **CORS**: Origin access is restricted at the Cloudflare/proxy level, with specific allowed origins configured.

- **Rate Limiting**: Implemented through Cloudflare/HTTPS server rate limiting rules rather than application-level middleware.

- **Security headers**: Implemented at proxy level:
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

#### Error Handling
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

### Testing Strategy
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
1. Simplicity over premature optimization
2. Standard Rails conventions where possible
3. Minimal external dependencies
4. Focus on maintainability
5. Preparation for future scaling where it doesn't add significant complexity

## Preferred Production Stack
For a production-ready application, the following stack would be chosen:

- **Database**: PostgreSQL with UUID primary keys
- **Background Jobs**: Sidekiq (or good_job for single-database setups)
- **Pagination**: Pagy for performance and simplicity
- **Authentication**: JWT tokens or HTTP-only cookies
- **API Layer**: Grape (with documentation) or GraphQL
- **Testing**: RSpec + factory_bot
- **Monitoring**: Sentry
- **Documentation**: Swagger/OpenAPI for REST or GraphiQL for GraphQL


## Assignment: Reedsy's (fictional) Merchandising Store

Reedsy would like to expand its business to include a merchandise store for our professionals. It will be comprised of 3 items:

```
Code         | Name                   |  Price
-------------------------------------------------
MUG          | Reedsy Mug             |   6.00
TSHIRT       | Reedsy T-shirt         |  15.00
HOODIE       | Reedsy Hoodie          |  20.00
```

We would like you to provide us with a small web application to help us manage this store.

### Guidelines

Some important notes before diving into the specifics:

- we expect this challenge to be done using Ruby on Rails;
- any detail that is not specified throughout this assignment is for you to decide. Our questions and examples are agnostic on purpose, so as to not bias your toward a specific format. If you work at Reedsy you will make decisions and we want that to reflect here. This being said, if you spot anything that you **really** think should be detailed here, feel free to let us know;
- the goal of this challenge is to see if you're able to write code that follows development best practices and is maintainable. It shouldn't be too complicated (you don't need to worry about authentication, for example) but it should be solid enough to ship to production;
- regarding dependencies:
    - try to keep them to a minimum. It's OK to add a dependency that adds a localized and easy to understand functionality;
    - avoid dependencies that significantly break away from standard Rails or that have a big DSL to learn (e.g., [Grape](https://github.com/ruby-grape/grape)). It makes it much harder for us to evaluate the challenge if it deviates a lot from vanilla Rails. If in doubt, err on the side of using less dependencies or check with us if it's OK to use;
- in terms of database any of SQLite, PostgreSQL or MySQL will be fine;
- include also with your solution:
    - instructions on how to setup and run your application;
    - a description of the API endpoints with cURL examples.

### Out of scope

Here's a non-exhaustive list of functionalities that you **don't** need to worry about in your solution:

- UI - the application should be API only, so don't include any sort of front-end;
- Swagger / Postman documentation or anything of that sort;
- authentication / authorization;
- filters / search / pagination;
- asynchronous jobs.

### How do I know when to stop adding more functionalities?

This challenge was designed to not take too much of your precious time. If it's taking you the whole day or more, maybe it's time to wrap up what you already have and ship it.

### Question 1

Implement an API endpoint that allows listing the existing items in the store, as well as their attributes.

### Question 2

Implement an API endpoint that allows updating the price of a given product.

### Question 3

Implement an API endpoint that allows one to check the price of a given list of items.

Some examples on the values expected:
```
Items: 1 MUG, 1 TSHIRT, 1 HOODIE
Total: 41.00
```

```
Items: 2 MUG, 1 TSHIRT
Total: 27.00
```

```
Items: 3 MUG, 1 TSHIRT
Total: 33.00
```

```
Items: 2 MUG, 4 TSHIRT, 1 HOODIE
Total: 92.00
```

### Question 4

We'd like to expand our store to provide some discounted prices in some situations.

- 30% discounts on all `TSHIRT` items when buying 3 or more.
- Volume discount for `MUG` items:
    - 2% discount for 10 to 19 items
    - 4% discount for 20 to 29 items
    - 6% discount for 30 to 39 items
    - ... (and so forth with discounts increasing in steps of 2%)
    - 30% discount for 150 or more items

Make the necessary changes to your code to allow these discounts to be in place and to be reflected in the existing endpoints. Also make your discounts flexible enough so that it's easy to change a discount's percentage (i.e., with minimal impact to the source code).

Here's how the above price examples would be updated with these discounts:
```
Items: 1 MUG, 1 TSHIRT, 1 HOODIE
Total: 41.00
```

```bash
curl -X POST "http://localhost:3000/api/v1/products/calculate" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"id": 1, "quantity": 1},
      {"id": 2, "quantity": 1},
      {"id": 3, "quantity": 1}
    ]
  }'
```

```
Items: 9 MUG, 1 TSHIRT
Total: 69.00
```

```bash
curl -X POST "http://localhost:3000/api/v1/products/calculate" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"id": 1, "quantity": 9},
      {"id": 2, "quantity": 1}
    ]
  }'
```

```
Items: 10 MUG, 1 TSHIRT
Total: 73.80

Explanation:
  - Total without discount: 60.00 + 15.00 = 75.00
  - Discount: 1.20 (2% discount on MUG)
  - Total: 75.00 - 1.20 = 73.80
```

```bash
curl -X POST "http://localhost:3000/api/v1/products/calculate" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"id": 1, "quantity": 10},
      {"id": 2, "quantity": 1}
    ]
  }'
```

```
Items: 45 MUG, 3 TSHIRT
Total: 279.90

Explanation:
  - Total without discount: 270.00 + 45.00 = 315.00
  - Discount: 21.60 (8% discount on MUG) + 13.50 (30% discount on TSHIRT) = 35.10
  - Total: 315.00 - 35.10 = 279.90
```

```bash
curl -X POST "http://localhost:3000/api/v1/products/calculate" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"id": 1, "quantity": 45},
      {"id": 2, "quantity": 3}
    ]
  }'
```

```
Items: 200 MUG, 4 TSHIRT, 1 HOODIE
Total: 902.00

Explanation:
  - Total without discount: 1200.00 + 60.00 + 20.00 = 1280.00
  - Discount: 360.00 (30% discount on MUG) + 18.00 (30% discount on TSHIRT) = 378.00
  - Total: 1280.00 - 378.00 = 902.00
```

```bash
curl -X POST "http://localhost:3000/api/v1/products/calculate" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"id": 1, "quantity": 200},
      {"id": 2, "quantity": 4},
      {"id": 3, "quantity": 1}
    ]
  }'
```

Once the challenge will be over, this repository will be moved to the private.
