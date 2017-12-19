# Catapult

## Dependencies
Uses Ruby 2.4.1 and Rails 5.1.4. 

## Setup
1. Run `bundle install` to install gems.
2. Run `rails db:setup` to create the database and run migrations.
3. Run tests with `rspec spec`

## Use
Start server `rails s`. Send a request to create a new breed
```
curl -X POST http://0.0.0.0:3000/breeds -H 'content-type: application/json' -d '{"breed": {"name": "Kitty"}}'
```

You should receive a response code 201 and a response with the newly created Breed.
```
{
    "id": 1,
    "name": "Kitty",
    "created_at": "2017-12-19T08:11:21.506Z",
    "updated_at": "2017-12-19T08:11:21.506Z",
    "tags": []
}
```

## Explanation
The app has three models, `Breed`, `Tag` and a join table in between called `Tagging`. The app just uses sqlite3 for storage since it's nice and lightweight but I would opt for a more robust database like Postgresql for production. 

The assigment specified to make sure that when a breed is deleted, the corresponding tags are removed if necessary so there are no orphaned tags. I added an after_destroy callback to the `Tagging` model that will delete the `Tag` if it isn't assigned to other breeds.

## Improvements
Both the BreedsController and TagsController have a stats action. If I had more time, I would have DRYed this up by adding a seperate StatsController to handle serving up stats for both Tags and Breeds.

I also should have cleaned up tests by using a library like FactoryGirl to make creation of future test fixtures less messy.