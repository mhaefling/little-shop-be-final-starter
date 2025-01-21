# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
    - Ruby 3.2.2
    - Rails 7.1.x

* System dependencies
    - Ruby on Rails
    - Ruby
    - PostgreSQL
    - Postman
    - Postico 2
    - Web Browswer (Chrome) - For FE
    - DevTools - For FE

* Configuration
    - Install Ruby:
        - `rbenv install 3.2.2`
        - NOTE: If rbenv tells you that the version you supplied is missing or not available, run:
            - `brew update && brew upgrade ruby-build`
        - Set Ruby 3.2.2 as the global version on your system by running:
            - `rbenv global 3.2.2`
    - Install Ruby on Rails
        - `gem install rails --version 7.1.3`
    - Start the server from within the project directory:
        - `rails server`
    - API URL:
        - IPv4:
            - http://127.0.0.1
            - Port: 3000
        - IPV6:
            - http://[::1]:3000
            - Port: 3000
        - Complete Paths:
            - http://127.0.0.1:3000
            - http://[::1]:3000
            - http://localhost:3000

* How to run the test suite
    - GEMs
        - "simplecov", require: false
        - "rspec-rails"
        - "pry"
        - "shoulda-matchers"
        - "pgreset"
    - Confirm all project GEMS have been installed by running:
        - `bundle install`
    - Confirm the correct `rspec-rails` version was installed by running:
        - `rspec -v`
        - Expected Output: `rspec-rails 7.1.0`
    - Run the test suite from the projects home directory:
        `bundle exec rspec`

* Database creation
    - `rails db:{drop,create}`
    - `runner ActiveRecord::Tasks::DatabaseTasks.load_seed`
    - `rails db:migrate`

* Database initialization
    - Ensure you have `PostgreSQL 14.14` installed.
    - `rails db:{drop,create}`
    - `runner ActiveRecord::Tasks::DatabaseTasks.load_seed`
    - `rails db:migrate`
    - Testing Database Connection:
        - Start the rails console from the project directory:
            `rails console`
        - Run the following command to confirm that all Merchants are being displayed:
            `Merchant.all`

* Available API Requests:
        - Returns all merchants in the database w/ coupon_count and invoice_coupon_count attributes
        - Returns all items in the database
        - Search by merchant's name using query `?name=`
        - Search by items's name using query `?name=`
        - Search by merchant's id
        - Search by item's id
        - Create a new merchant `{ "name": "new merchant name" }`
        - Create a new item `{ "name": "item_name", "description": "item_description", "unit_price": item_price, "merchant_id": item_merchant_id }`
        - Update an existing merchant by id
        - Update an existing item by id
        - Delete an existing merchant by id
        - Delete an existing item by id
        - Search all items by merchant id
        - Search merchant by item id
        - Search customers by merchant id
        - Search invoices by merchant id
        - Search items by minimum price `?min_price=`
        - Search items by maximum price `?max_price=`
        - Search items by minimum price to maximum price `?max_price=&min_price=`
        - Show Coupon by id
        - Show a Merchants Coupon Index
        - Create a new Coupon
        - Deactivate an existing Coupon
        - Activate an existing Coupon

* Authors:
    - Matt Haefling
        - [LinkedIn](https://www.linkedin.com/in/matthew-haefling/)
        - [Github](https://github.com/mhaefling)
