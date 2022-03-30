# PrepareDinner v0.1-beta
[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)
PrepareDinner is an awesome app offering users to search through relevant recipes for dinner, based on the available ingredients currently at home.

You may check the app at
https://pl-recipes-achamakiotis.herokuapp.com/

Stack:
- Ruby 3.1.1
- Rails 7.0
- MySQL (gem 0.5.3)
- React 17.0.2
- ReactDom 17.0.2
- Minitest 5.15.0

_Deployed on hobby Heroku dyno with ClearDB_


| Feature |
| ------ |
| _Search Recipes:_ |
| As a guest user i want to be able to make a search with one or multiple ingredients and get relevant recipes. |
| _Acceptance:_ |
| Given i am a guest user, when i open the home page, system should show me a search input. Once i enter one or multiple ingredients and click enter, the system should show recipes matched my criteria and ordered by a relevance score and ratings |

# Data Structure

There are two different implementation approches of the app depending on the hardware specifications and limitations of the system being deployed on.

```
  Recipe:
    :title
    :cook_time
    :prep_time
    :total_cooking_time
    :ratings
    :recipe_category
    :image_url
    :jsoningredients
    
Ingredient:
    :id
    :name
    
RecipeIngredient:
    :id
    :ingredient_id
    :recipe_id
```

The reason i have left both implementations is only for assignement demonstration and needs further discussion with the team regarding which one should be picked in production and why. Given the fact I wanted to deploy in heroku, keep the Ingredients in a serialized hash in Recipe model was the a viable solution.

# Run project locally
Prepare your system with the above mentioned dependencies. Depending your OS, consider adding your architecture platform.
For example:
```
bundle add --platform x86_64-linux
```

--add-platform
Add a new platform to the lockfile, re-resolving for the addition of that platform.

Once you are have the env set, run the following.

```sh
git clone git@github.com:remoteweb/pl-recipes-achamakiotis.git
cd pl-recipes-achamakiotis
bundle install
rake test
rake import_recipes\["json"\]
./bin/dev
```



<!-- # Heroku Test Pass

```
``` -->

# Local Test Pass

```
Running 4 tests in a single process (parallelization threshold is 50)
Run options: --seed 46295

# Running:

..Importing Records is taking:
10013 recipes imported
1.55 seconds
Test search results relevance
.Importing Records is taking:
10013 recipes imported
1.5 seconds
Test search results performance
Search for bacon,eggs,cucumber,potato is taking:
1.76 seconds
.

Finished in 6.871504s, 0.5821 runs/s, 1.1642 assertions/s.
4 runs, 8 assertions, 0 failures, 0 errors, 0 skips
```
