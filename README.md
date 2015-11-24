# Roda::Tags

A [Roda](http://roda.jeremyevans.net/) plugin providing easy creation of flexible HTML tags within Roda apps or Roda plugins.

Extensively tested and with 100% code test coverage.


## Installation

To use this gem, just do

```bash  
$ (sudo) gem install roda-tags
```

or preferably add this to your Gemfile for Bundler


```ruby
gem 'roda-tags'
```

<br>

## Getting Started

To use Roda::Tags just ensure the gem is included in the Gemfile and then...

...add the plugin to your app...

```bash
class MyApp < Roda
  
  plugin :tags  # see Configurations below for options
  # or
  plugin :tag_helpers # , options
  
  # <snip...>  
end
```

...or include the plugin in your own Roda plugin.

```ruby
class Roda
  module RodaPlugins
    module YourPlugin
      
      def self.load_dependencies(app, opts={})
        app.plugin :tags, opts
        # or
        app.plugin :tag_helpers, opts
      end
      
      # <snip...>
    end
  end
end
```
<br>

## Usage



<br>

## Key Methods / Functionality


<br>


Roda::Tags contains two plugins - [`:tags`, `:tag_helpers`] - that can be used independently or together.

**Note!** The `:tags` plugin is loaded by the `:tag_helpers` plugin.

<br>

## 1. `:tags` Plugin


This plugin have one **key public method** - `tag()`, which supports this **dynamic** syntax:


### -- `tag(*args, &block)`


```ruby
tag(name)
tag(name, &block)

tag(name, content)
tag(name, content, attributes)
tag(name, content, attributes, &block)

tag(name, attributes)
tag(name, attributes, &block)
```

This makes the method very flexible as can be seen below.


#### Self closing tags

```ruby
tag(:br)   #=> <br> or <br/> if XHTML

tag(:hr, class: :divider)  #=>  <hr class="divider">
```

#### Multi line tags

```ruby
tag(:div)  #=>  <div></div>

tag(:div, 'content') 
  #  <div>
  #    content
  #  </div>

tag(:div, 'content', id: 'comment') 
  #  <div id="comment">
  #    content
  #  </div>
    

 # NB! no content
tag(:div, id: :comment) 
  #=> <div id="comment"></div>
   
```

#### Single line tags

```ruby
tag(:h1,'Header')  #=>  <h1>Header</h1>

tag(:abbr, 'UN', title: "United Nations")  #=>  <abbr title="United Nations">UN</abbr>
```

#### Working with blocks

```ruby
tag(:div) do
  tag(:p, 'Hello World')
end
  #  <div>
  #    <p>Hello World</p>
  #  </div>

  
<% tag(:ul) do %>
  <li>item 1</li>
  <%= tag(:li, 'item 2') %>
  <li>item 3</li>
<% end %>
  #  <ul>
  #    <li>item 1</li>
  #    <li>item 2</li>
  #    <li>item 3</li>
  #  </ul>


 # NOTE: ignores tag contents when given a block
<% tag(:div, 'ignored tag-content') do %>
  <%= tag(:label, 'Comments:', for: :comments) %>
  <%= tag(:textarea,'textarea contents', id: :comments) %>
<% end %>
  #  <div>
  #    <label for="comments">Comments:</label>
  #    <textarea id="comments">
  #      textarea contents
  #    </textarea>
  #  </div>
```


#### Boolean attributes

```ruby
tag(:input, type: :checkbox, checked: true)
  #=> <input checked="checked" type="checkbox">

tag(:option, 'Roda', value: "1" selected: true)
  #=> <option selected="selected" value="1">Roda</option>
  
tag(:option, 'PHP', value: "0" selected: false)
  #=> <option value="0">PHP</option>
```

<br>

The plugin also have a few other public helper methods:


### -- `merge_attr_classes(attr, *classes)`

Updates `attr[:class]` in the hash with the given `classes` and returns `attr`.
    
```ruby
attr = { class: 'alert', id: :idval }
    
merge_attr_classes(attr, 'alert-info')  
  #=> { class: 'alert alert-info', id: :idval }
    
merge_attr_classes(attr, [:alert, 'alert-info'])  
  #=> { class: 'alert alert-info', id: :idval }
```
    
<br>



### -- `merge_classes(*classes)`
    
Returns an alphabetised string from all given class values.

The method correctly handles a combination of `arrays`, `strings` & `symbols` being passed in.
    
```ruby
attr = { class: 'alert', id: :idval }
    
merge_classes(attr[:class], ['alert', 'alert-info'])  #=> 'alert alert-info'
    
merge_classes(attr[:class], :text)  #=> 'alert text'
    
merge_classes(attr[:class], [:text, :'alert-info'])  #=> 'alert alert-info text'
```

<br>

### Included Helper methods 

The `:tags` plugin also includes a few useful public helper methods for use within other methods or gems.


### -- `capture(block='')`

Captures and returns a captured `ERB` block and restores the buffer afterwards.
 
<br>
    

### -- `capture_html(*args, &block)`

Captures the HTML from a block of template code for `ERB` or `HAML`.

```ruby
def some_method(*args, &block)
 # <snip...>
 res = capture_html(&block)
 # <snip...>
end
```
    
<br>


### -- `concat_content(text="")`

Outputs the given content to the buffer directly.
  
```ruby
concat_content("This will be concatenated to the buffer")
```
    
<br>
      

### -- `block_is_template?(block)`

Returns `true` if the block is from an `ERB` or `HAML` template; `false` otherwise. Used to determine if contents should be returned or concatenated to output.

<br>

---

<br>


## 2. `:tag_helpers` Plugin

<br>

#### -- `form_tag(action, attrs={}, &block)`

Constructs a `<form>` without an object based on options passed.

```ruby
form_tag('/register') do 
 ... 
end
 #   <form action="/register" id="register-form" method="post">
 #    ...
 #   </form>
```
Automatically adds a hidden *faux method* when `:method` is NOT either `POST` or `GET`.

```ruby
form_tag('/user/1/profile', method: :put, id: 'profile-form')
  ...
end
  #  <form action="/user/1/profile" id="profile-form" method="post" >
  #    <input name="_method" type="hidden" value="put"/>
  #    ...
  #  </form>
```

Add multipart support via:

```ruby
form_tag('/upload', multipart: true)
 # or
form_tag('/upload', multipart: 'multipart/form-data')
 # or
form_tag('/upload', enctype: 'multipart/form-data')
  #  <form enctype="multipart/form-data" method="post" action="/upload">
  #     ...
  #  </form>
```

<br>
---


### -- `label_tag(field, attrs={}, &block)`
 
Constructs a `<label>` tag from the given options. 


By default appends `':'` to the label name, based upon the plugin config `:tags_label_append ` value.

```ruby
label_tag(:name)
  #=> <label for="name">Name:</label>
     
label_tag(:name, label: 'Custom label', class: 'sr-only')
  #=> <label class="sr-only" for="name">Custom label:</label>

 # uses a humanized version of the label name if { label: nil } 
label_tag(:name, label: nil)
  #=> <label for="name">Name:</label>

 # removes the label text when { label: :false }
label_tag(:name, label: false)
  #=> <label for="name"></label>
```

By default adds `'<span>*</span>'` to the label name when `{ required: true }` is passed. Based upon the plugin config `:tags_label_required_str ` value.


```ruby
label_tag(:name, required: true)
  #=> <label for="name">Name: <span>*</span></label>
```

Label tags also supports passing blocks.

```ruby
<% label_tag(:remember_me) do %>
  <%= checkbox_tag :remember_me %>
<% end %>
  #  <label for="remember_me">Remember Me:
  #    <input class="checkbox" id="remember_me" name="remember_me" type="checkbox" value="1">
  #  </label>
```


<br>
---

### -- `hidden_field_tag(name, attrs={})`

        
Constructs a hidden input field from the given options. Only `[:value, :id, :name]` attributes are allowed.


```ruby
hidden_field_tag(:snippet_name)
  #=> <input id="snippet_name" name="snippet_name" type="hidden">

hidden_field_tag(:csrf, value: 'tokenval')
  #=> <input id="csrf" name="csrf" type="hidden" value="tokenval">

hidden_field_tag(:snippet_id, id: 'some-id')
  #=> <input id="some-id" name="snippet_id" type="hidden">

 # removing the `:id` attribute completely.
hidden_field_tag(:snippet_name, id: false)
  #=> <input name="snippet_name" type="hidden">
``` 

<br>
---

### -- `text_field_tag(name, attrs={}) `
 &nbsp; - *also aliased as* `textfield_tag()`
        
Creates a standard `<input type="text"...>` field from the given options.

```ruby
text_field_tag(:snippet_name)
  #=> <input class="text" id="snippet_name" name="snippet_name" type="text">

text_field_tag(:name, value: 'some-value')
  #=> <input class="text" id="name" name="name" type="text" value="some-value">

text_field_tag(:name, id: 'some-id')
  #=> <input class="text" id="some-id" name="name" type="text">

 # removing the `:id` attribute completely. NB! bad practice.
text_field_tag(:name, id: false)
  #=> <input class="text" name="name" type="text">

 # append a CSS class to the existing class.
text_field_tag(:name, class: :big)
  #=> <input class="big text" id="name" name="name" type="text">

 # adds a `:title` attribute when passed `:ui_hint`
text_field_tag(:name, ui_hint: 'a user hint')
  #=> <input class="text" id="name" name="name" title="a user hint" type="text">

 # supports `:maxlength` & `:size` attributes
text_field_tag(:ip, maxlength: 15, size: 20)
  #=> <input class="text" id="ip" maxlength="15" name="ip" size="20" type="text">

 # `:disabled` attribute
text_field_tag(:name, disabled: true)
  #=> <input class="text" disabled="disabled" id="name" name="name" type="text">

 # `:readonly` attribute
text_field_tag(:name, readonly: true)
  #=> <input class="text" id="name" name="name" readonly="readonly" type="text">
```

<br>
---

### -- `password_field_tag(name, attrs={})`
 &nbsp; - *also aliased as* `passwordfield_tag()`
    
Constructs a `<input type="password"...>` field from the given options.

```ruby
password_field_tag(:snippet_name)
  #=> <input class="text" id="snippet_name" name="snippet_name" type="password">

password_field_tag(:snippet_name, value: 'some-value')
  #=> <input class="text" id="snippet_name" name="snippet_name" type="password" value="some-value">

password_field_tag(:snippet_name, id: 'some-id')
  #=> <input class="text" id="some-id" name="snippet_name" type="password">

password_field_tag(:snippet_name, id: false)
  #=> <input class="text" name="snippet_name" type="password">

 # append a CSS class to the existing class. Default class: `.text`.
password_field_tag(:snippet_name, class: :big )
  #=> <input class="big text" id="snippet_name" name="snippet_name" type="password">

 # adds a `:title` attribute when passed `:ui_hint`
password_field_tag(:name, ui_hint: 'a user hint')
  #=> <input class="text" id="name" name="name" title="a user hint" type="password">

 # supports `:maxlength` & `:size` attributes
password_field_tag(:ip_address, maxlength: 15, size: 20)
  #=> <input class="text" id="ip_address" maxlength="15" name="ip_address" size="20" type="password">

 # `disabled` attribute
password_field_tag(:name, disabled: true)
password_field_tag(:name, disabled: :disabled)
  #=> <input class="text" id="name" disabled="disabled" name="name" type="password">
```

<br>
---

        
### -- `file_field_tag(name, attrs={})`
 &nbsp; - *also aliased as* `filefield_tag()`

Creates an `<input type="file"...>` field from given options. 

**NOTE!** If you are using file uploads then you will also need to set the multipart option for the form tag, like this:

```ruby
<% form_tag('/upload', multipart: true) do %>
  <%= label_tag(:file, label: "File to Upload") %>
  <%= file_field_tag "file" %>
  <%= submit_tag %>
<% end %>
```

The specified URL will then be passed a File object containing the selected file, or if the field was left blank, a StringIO object.


```ruby
file_field_tag('attachment')
  #=> <input class="file" id="attachment" name="attachment" type="file">

 # ignores invalid :value attribute.
file_field_tag(:photo, value: 'some-value')
  #=> <input class="file" id="photo" name="photo" type="file">

file_field_tag(:photo, id: 'some-id')
  #=> <input class="file" id="some-id" name="photo" type="file">

 # removing the `:id` attribute completely. NB! bad practice.
file_field_tag(:photo, id: false)
  #=> <input class="file" name="photo" type="file">

 # append a CSS class to the existing class. Default class: `.file`.
file_field_tag(:photo, class: :big )
  #=> <input class="big file" id="photo" name="photo" type="file">

 # adds a `:title` attribute when passed `:ui_hint`.
file_field_tag(:photo, ui_hint: 'a user hint')
  #=> <input class="file" id="photo" name="photo" title="a user hint" type="file">

 # `:disabled` attribute
file_field_tag(:photo, disabled: true)
  #=> <input class="file" disabled="disabled" id="photo" name="photo" type="file">

 # `:accept` attribute is subject to actual browser support.
file_field_tag(:photo, accept: 'image/png,image/jpeg' )
  #=> <input accept="image/png,image/jpeg" class="file" id="photo" name="photo" type="file">
```

<br>
---


### -- `textarea_tag(name, attrs={})`
 &nbsp; - *also aliased as* `text_area_tag()`

Constructs a textarea input from the given options.

**TODO:** enable :escape functionality. How??

* `:escape` - By default, the contents of the text input are HTML escaped. If you need unescaped contents, set this to false.


```ruby
textarea_tag('post')
  #=> <textarea id="post" name="post">\n</textarea>

 # add a value
textarea_tag(:bio, value: @actor.bio)
  #=> <textarea id="bio" name="bio">This is my biography.\n</textarea>

 # set a different :id
textarea_tag(:body, id: 'some-id')
  #=> <textarea id="some-id" name="post">...</textarea>

 # adds a CSS class. NB! :textarea have no default class.
textarea_tag(:body, class: 'big')
  #=> <textarea class="big" id="post" name="post">...</textarea>

 # adds a `:title` attribute when passed `:ui_hint`
textarea_tag(:body, ui_hint: 'a user hint')
  #=> <textarea id="post" name="post" title="a user hint">...</textarea>

 # supports `:rows` & `:cols` attributes
textarea_tag('body', rows: 10, cols: 25)
  #=> <textarea cols="25" id="body" name="body" rows="10">...</textarea>

 # alternative `:size` shortcut to set `:rows` & `:cols` 
textarea_tag('body', size: "25x10")
  #=> <textarea cols="25" id="body" name="body" rows="10">...</textarea>

 # `:disabled` attribute
textarea_tag(:description, disabled: true)
  #=> <textarea disabled="disabled" id="description" name="description">...</textarea>
 
 # `:readonly` attribute
textarea_tag(:description, readonly: true)
  #=> <textarea id="description" name="description" readonly="readonly">...</textarea>
```  

<br>
---

### -- `field_set_tag(*args, &block)`
 &nbsp; - *also aliased as* `fieldset_tag()`
        
Creates a `<fieldset..>` tag for grouping HTML form elements.

```ruby
field_set_tag(:actor)
  #  <fieldset id="fieldset-actor">
  #    <legend>Actor</legend>
  #     ...
  #  </fieldset>

 # sets the `<legend>` and `:id` attribute when given a single argument.
field_set_tag('User Details') do
  ...
end
  #  <fieldset id="fieldset-user-details">
  #    <legend>User Details</legend>
  #    ...
  #  </fieldset>

 # supports `:legend` attribute
field_set_tag(:actor, legend: 'Details')
  #  <fieldset id="fieldset-actor">
  #    <legend>Details</legend>
  #    <snip...>

 # remove `<legend>` tag by  `{ legend: false }`
field_set_tag(:actor, legend: 'Details')
  #  <fieldset id="fieldset-actor">
  #    <legend>Details</legend>
  #    <snip...>

 # append a CSS class. NB! fieldset has no other class by default.
field_set_tag(:actor, class: 'legend-class')
  #  <fieldset class="legend-class" id="fieldset-actor">
  #    <snip...>

 # default to 'fieldset' when passed `nil` as the first arg
field_set_tag(nil, class: 'format')
  #  <fieldset class="format" id="fieldset">
  #    <snip...>

 # removing the `:id` attribute completely
field_set_tag('Users', id: false)
  #  <fieldset>
  #    <legend>Users</legend>
  #    <snip...>
```

<br>
---

### -- `legend_tag(contents, attrs={})`
        
Return a legend with _contents_ from the given options.


```ruby
legend_tag('User Details')
  #=> <legend>User Details</legend>

 # adding an :id attribute.
legend_tag('User', id: 'some-id')
  #=> <legend id="some-id">User</legend>

 # adds a CSS class. NB! legend tags have no default class
legend_tag('User', class: 'some-class')
  #=> <legend class="some-class">User</legend>
```

<br>
---


### -- `check_box_tag(name, attrs={})`
&nbsp; - also aliased as `checkbox_tag()`
        
Creates an `<input type="checkbox"...>` tag from the given options.


```ruby
check_box_tag(:accept) || checkbox_tag(:accept)
  #=> <input class="checkbox" id="accept" name="accept" type="checkbox" value="1">

 # providing a value
check_box_tag(:rock, value: 'rock music')
  #=> <input class="checkbox" id="rock" name="rock" type="checkbox" value="rock music">

 # setting a different :id
check_box_tag(:rock, :id => 'some-id')
  #=> <input class="checkbox" id="some-id" name="rock" type="checkbox" value="1">

 # append a CSS class. NB! default class: '.checkbox'
check_box_tag(:rock, class: 'small')
  #=> <input class="small checkbox" id="rock" name="rock" type="checkbox" value="1">

 # adds a `:title` attribute when passed `:ui_hint`
check_box_tag(:rock, ui_hint: 'a user hint')
  #=> <input class="checkbox" id="rock" name="rock" title="a user hint" type="checkbox" value="1">

 # `checked` attribute
check_box_tag(:rock, checked: true)
  #=> <input checked="checked" class="checkbox" id="rock" name="rock" type="checkbox" value="1">

 # `disabled` attribute
check_box_tag(:rock, disabled: true)
  #=> <input class="checkbox" disabled="disabled" id="rock" name="rock" type="checkbox" value="1">
```

<br>
---

### -- `radio_button_tag(name, attrs={})`
&nbsp; - *also aliased as* `radiobutton_tag()`
        
Creates a `<input type="radio"...>` tag from the given options.

**NOTE!** use groups of radio buttons named the same to allow users to select from a group of options.


```ruby
radio_button_tag(:accept) || radiobutton_tag(:accept)
  #=> <input class="radio" id="accept_1" name="accept" type="radio" value="1">

radio_button_tag(:rock, value:'rock music')
  #=> <input class="radio" id="rock_rock-music" name="rock" type="radio" value="rock music">

 # setting a different :id.
radio_button_tag(:rock, id: 'some-id')  
  #=> <input class="radio" id="some-id_1" name="rock" type="radio" value="1">

 # append a CSS class. NB! default class: '.radio'
radio_button_tag(:rock, class: 'big')  
  #=> <input class="big radio" id="rock_1" name="rock" type="radio" value="1">

 # adds a `:title` attribute when passed `:ui_hint`
radio_button_tag(:rock, ui_hint: 'a user hint')  
  #=> <input class="radio" id="rock_1" value="1" name="rock" title="a user hint" type="radio">

 # `checked` attribute
radio_button_tag(:yes, checked: true)
  #=> <input checked="checked" class="radio" id="yes_1" name="yes" type="radio" value="1">

 # `disabled` attribute
radio_button_tag(:yes, disabled: true)
  #=> <input disabled="disabled" class="radio" id="yes_1" name="yes" type="radio" value="1">
```

<br>
---


### -- `submit_tag(value="Save Form", attrs={})` 
&nbsp; - *also aliased as*  **`submit_button()`**
        
Creates a submit button with the text value as the caption.

```ruby
submit_tag()  || submit_button()
  #=> <input name="submit" type="submit" value="Save Form">

submit_tag(nil)
  #=> <input name="submit" type="submit" value="">
  
submit_tag('Custom Value')
  #=> <input name="submit" type="submit" value="Custom Value">

 # adds a CSS class. NB! input[:submit] has no other class by default.
submit_tag(class: 'some-class')
  #=> <input class="some-class" name="submit" type="submit" value="Save Form">

 # supports the :disabled attribute.
submit_tag('disabled: true)
  #=> <input disabled="disabled" name="submit" type="submit" value="Save Form">

 # adds a `:title` attribute when passed `:ui_hint`.
submit_tag(ui_hint: 'a user hint')
  #=> <input name="submit" title="a user hint" type="submit" value="Save Form">
```

<br>
---

### -- `image_submit_tag(src, attrs={})`

Adds a `<input src=""...>` tag which displays an image.
 

```ruby
@img = '/img/btn.png'

image_submit_tag(@img)
  #=> <input src="/img/btn.png" type="image">

image_submit_tag(@img, disabled: true)
  #=> <input disabled="disabled" src="/img/btn.png" type="image">

image_submit_tag(@img, class 'search-button')
  #=> <input class="search-button" src="/img/btn.png" type="image">
```

<br>
---

### -- `reset_tag(value='Reset Form', attrs={})`
&nbsp; - *also aliased as*  **`reset_button()`**

Creates a reset button with the text value as the caption.

```ruby
reset_tag() || reset_button()
  #=> <input name="reset" type="reset" value="Reset Form">

reset_tag(nil)
  #=> <input name="reset" type="reset" value="">

reset_tag('Custom Value')
  #=> <input name="reset" type="reset" value="Custom Value">

 # adds a CSS class. NB! input[:reset] has no other class by default
reset_tag(class: 'some-class')
  #=> <input class="some-class" name="reset" type="reset" value="Reset Form">

 # supports the `:disabled` attribute
reset_tag(disabled: true)
  #=> <input disabled="disabled" name="reset" type="reset" value="Reset Form"> 

 # adds a `:title` attribute when passed `:ui_hint`
reset_tag(ui_hint: 'a user hint')
  #=> <input name="reset" title="a user hint" type="submit" value="Reset Form">
```

<br>
---

### -- `select_tag(name, options, attrs={})`
        
Creates a `<select..>` tag (dropdown menu), including the various select options.


**Note!** the format for the options values must be `[value, key]`.

Passing options values as a `Hash`.

```ruby
select_tag(:letters, {a: 'A', b: 'B' })
  #  <select id="letters" name="letters">
  #   <option value="a">A</option>
  #   <option value="b">B</option>
  #  </select>
```

Passing options values as an `Array`.

```ruby
@letters = [[:a,'A'], [:b,'B']]

select_tag(:letters, @letters)
  #  <select id="letters" name="letters">
  #    <option value="a">A</option>
  #    <option value="b">B</option>
  #  </select>
```

Handling passed options:

```ruby
select_tag(:letters, @letters, disabled: true)
  #  <select id="letters" disabled="disabled" name="letters">
  #    <snip...>

select_tag(:letters, @letters, id: 'my-letters')
  #  <select id="my-letters" name="letters">
  #    <snip...>

select_tag(:letters, @letters, class: 'funky-select')
  #  <select class="funky-select" id="my-letters" name="letters">
  #    <snip...>
```

Handling the prompt value:

```ruby
select_tag(:letters, @letters, prompt: true)
   #  <select id="letters" name="letters">
   #    <option selected="selected" value="">- Select -</option>
   #    <snip...>

 # setting a custom prompt
select_tag(:letters, @letters, prompt: 'Top Letters', selected: 'a')
   #  <select id="letters" name="letters">
   #    <option value="">Top Letters</option>
   #    <option selected="selected" value="a">A</option>
   #    <snip...>
```

Adding `:selected` option.

```ruby
select_tag(:letters, @letters, selected: :a)
  #  <select id="letters" name="letters">
  #    <option selected="selected" value="a">A</option>
  #    <snip...>
```


When passing multiple items to `:selected` option or setting the `{ multiple: true }` option, the select menu automatically becomes a multiple select box.

**NOTE!** the `name="letters[]"` attribute.

```ruby
select_tag(:letters, @letters, selected: [:a,'b'])
  #  <select id="letters" multiple="multiple" name="letters[]">
  #    <option selected="selected" value="a">A</option>
  #    <option selected="selected" value="b">B</option>
  #  </select>

select_tag(:letters, @letters, multiple: true)
  #  <select id="letters" name="letters[]" multiple="multiple">
  #    <snip...>
```

<br>
---

### -- `select_option(value, key, attrs={})`      

Creates an `<option...>` tag for `<select...>` menus.

```ruby
select_option('a', 'Letter A')
  #=> <option value="a">Letter A</option>

select_option('on', '')  # , nil)
  #=> <option value="on">On</option>
 
 # handling selected options
select_option('a', 'Letter A', selected: true)
  #=> <option selected="selected" value="a">Letter A</option>

select_option('a', 'Letter A', selected: false)
  #=> <option value="a">Letter A</option>
```

<br>
---

### -- `faux_method(method='PUT')`


```ruby
 faux_method() #=> <input name="_method" type="hidden" value="PUT">

 # handling DELETE requests
 faux_method(:delete) #=> <input name="_method" type="hidden" value="DELETE">
 
```     

<br>
---

## Plugin Configurations

The default settings should help you get moving quickly, and are fairly common sense based.

However the `:tags` plugin supports these config options:

#### `:tag_output_format_is_xhtml`

Sets the HTML output format, toggling between `HTML 5` (`false`) and `XHTML` (`true`). Default is: `false`.

This option is retained for legacy support and in memory of the *"good old days"* ;-).

#### `:tag_add_newlines_after_tags`

Sets the formatting of the HTML output, whether it should be more compact in nature or slightly better formatted. Default is: `true`.


The `:tag_helpers` plugin supports these config options:


#### `:tags_label_required_str`

Sets the formatting of the string appended to required `<label...>` tags. Default is: `'<span>*</span>'`.

#### `:tags_label_append_str`

Sets the formatting of the string appended to `<label...>` tags. Default is: `':'`.


#### `:tags_forms_default_class`

Sets the default class value for form tags. Default is: `''` (empty).

This is a shortcut to automatically add something like [Bootstrap](https://getbootstrap.com/)  support with `'form-control'`


**NOTE!** 

Config options set in `:tag_helpers` are passed on to the `:tags` plugin.

```ruby
 # <snip...>
 # support legacy XHTML formatted output
plugin :tag_helpers, { tag_output_format_is_xhtml: true, ... }
 # <snip...>
```



## RTFM

If the above is not clear enough, please check the specs for a better understanding.

<br>

## Errors / Bugs

If something is not behaving intuitively, it is a bug, and should be reported.
Report it here: http://github.com/kematzy/roda-tags/issues 

<br>

## TODOs

* Keep it up to date with any changes in `Roda` or `HTML`.

* Decide on if it's worth it to do validity checks on all attributes passed to tags 
  ie: reject attributes based upon what is allowed for the tag. 
    
    ```ruby
    tag(:base, href: 'url', target: '_self', id: 'is-ignored') 
      #=> <base href="url", target="_self">
    ```

* Decide on whether to add a number of convenience tags (methods), such as:
  
    - ```meta(name, contents)```
    
    - ```img(src, attrs={})```
  

* Any other improvements we may think of.


<br>

## Dependencies

This Gem depends upon the following:

### Runtime:

* roda (>= 2.5.0)
* tilt 
* erubis


### Development & Tests:

* bundler (~> 1.10)
* rake  (~> 10.0)
* minitest
* minitest-hooks
* minitest-rg
* rack-test
* nokogiri  => for the `assert_have_tag()` tests

* simplecov


<br>

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with Rakefile, version, or history.
  * (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.


<br>

## Copyright

Copyright (c) 2010-2015 Kematzy

Released under the MIT License. See LICENSE for further details.

<br>

## Code Inspirations:

* The ActiveSupport gem by DHH & Rails Core Team



