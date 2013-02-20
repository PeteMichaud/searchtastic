# Searchtastic

Searchtastic makes it possible to filter any collection of ActiveRecord models automatically based on any field,
including associated fields not even on the model itself. It's kind of awesome.

# Installation

In Rails 3, add this to your Gemfile and run the `bundle` command.

```ruby
gem 'searchtastic'
```

# Basic Usage

### 1. Set up Your Models

Make a model searchable by providing an array of attributes to search on:

```ruby
class User < ActiveRecord::Base
    attr_accessible :name, :bio
    has_one :club, class_name: Organization
    searchable_by :name, :bio, :'club.name'
end
```

### 2. Perform the Search

Searching works anywhere, but normally you'll search from within a controller action:

```ruby
...
def index
    #@filter == "test"
    @users = User.search(@filter)
    ...
end
...
```

Note that this works for any ActiveRelation so this will work as well:

```ruby
...
def index
    #@filter == "pete"
    @users = @foo.users.search(@filter)
    ...
end
...
```

# To Do

*   Search on combined fields, e.g. first_name + last_name
*   Search on all accessible attributes shorthand
*   Search on Date Ranges
*   Search against has_many :through associations
*   Search against HABTM associations

# Contributors

`searchtastic` is solely Pete Michaud's (me@petermichaud.com) fault, so blame him for everything.

# License

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.