# PrepareDinner v0.1-beta
[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)
Recipes Finder v0.9 is an awesome app offering users to search through relevant recipes for dinner, based on the available ingredients currently at home.

You may check the app at
https://pl-recipes-achamakiotis.herokuapp.com/

Stack:
- Ruby 3.1.1
- Rails 7.0
- MySQL 8.0.28 (gem 0.5.3)
- React 17.0.2
- ReactDom 17.0.2
- Minitest 5.15.0

_Deployed on basic Heroku dyno with ClearDB_

# Run project locally
Prepare your system with the above mentioned dependencies. Depending your OS, you might
need to add your architecture platform.

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
