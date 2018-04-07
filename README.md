# Http Status Rails
This gem makes http status rendering cool. It provides a minimal rendering content for every status and format included in Ruby On Rails.

## Usage

### Basic

To render a status in a controller, you can just call the `render_status` method:

```ruby
def show
 @user = User.find_by id: params[:id]
 render_status :not_found if @user.nil?
end
```

Depending on the request format, it will respond with a basic message:

#### HTML

```html
<!-- Wrapped into layouts/application by default -->
<h1>404 Not Found</h1>
<p>The page you are looking for does not exist.</p>
```

#### JSON

```json
{
  "status": 404,
  "title": "Not Found",
  "message": "The page you are looking for does not exist."
}
```

#### Formats supported by default
- text
- json
- yaml
- xml
- svg
- js
- html
- rss
- atom
- ics
- csv

If the request format isn't in this list and you haven't created any template to handle it, the server will respond with a **html** format (The *Restrict render format* section explain how to customize this behavior).

You can also explicitly set the rendering format or the layout:

```ruby
render_status :bad_request, format: :js, layout: 'layouts/status'
# Set layout to false if you doesn't want any layout
# If the layout isn't found for the given format, it's assumed to be false
```

The response could be:

```javascript
// Asuming that layouts/status.js.erb wraps JavaScript into a jQuery callback
$(function() {
  window.http = { "code": 400, "title": "Bad Request", "message": "The server cannot or will not process the request due to something that is perceived to be a client error." }
});
```

### Templating

You can override these responses or create new ones by adding `status` named templates in the `app/views/http` folder. (eg: `app/views/http/status.html.erb`, `app/views/http/status.csv.erb`)

You'll have access to a `@status` variable which contains the following methods:
- `key`: The symbol you provided to the `render_status` method. (If this symbol isn't registered by Rails within valid http status, it'll be replaced by `:internal_error`)
- `code`: The code corresponding to the status. (eg: for `:not_found` it'll be `404`)
- `title`: The title of the status (eg: for `:not_found` it'll be «*Not Found*»)
- `message`: The message of the status (eg: for `:not_found` it'll be «*The page you are looking for does not exist.*»)
- `error?`: Indicates if the status is considered as an error (4xx and 5xx codes).

### Layout

You can configure the layout you want to use in your controller with the `status_layout` method:

```
class ApplicationController < ActionController::Base
    status_layout 'status' # By default: 'application'
    # If the layout isn't found for the current format, it's assumed to be false
end
```

### Localizing

This gem uses `I18n` to provide localized contents. You can override or translate these contents by adding new yaml keys under the `config/locales` folder:

```yaml
fr:
  http_status:
    not_found:
      code: 404
      title: Page introuvable
      message: La page que vous recherchez n'existe pas
```

Every key which lives directly under `http_status` exactly matches the corresponding status symbol provided by Rails.

### Helpers

#### Handle *Not Found*

You can easily handle *Not Found* status by calling the `handles_not_found_status` method in a controller **and** in the `config/routes.rb` file:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  handles_not_found_status
end
```

```ruby
# config/routes.rb
Rails.application.routes.draw do

  # ...

  handles_not_found_status # Put this at the very bottom of the block
end
```

This method will respond with a *Not Found* page (in html, json, ...) when a record isn't found (eg: `User.find params[:id]`), or when there is any routing problem (controller not found, action not found).

#### Handle generic errors (as error 500)

You can easily handle generic exceptions within your controller by calling the `handles_error_status` method.

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  handles_error_status
end
```

This method will respond with a *Internal Server Error* page (in html, json, ...) when any error occurs while handling the request.

#### Restrict render formats

Http status will all be rendered in json, whatever the request format is:
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  status_formats only: :json
end
```

Http status will all be rendered in json or html, but will fallback on html because it's the first one:
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  status_formats only: [:html, :json]
end
```

Http status will be rendered in html for csv, yaml and rss formats:
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  status_formats except: [:csv, :yaml, :rss]
end
```

Http status will be rendered in json for csv, yaml and rss formats, or when the format is unknown, or when json is the original request format. The status will be rendered in html when it's the original request format:
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  status_formats except: [:csv, :yaml, :rss], only: [:json, :html]
end
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'httpstatus-rails'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install httpstatus-rails
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
