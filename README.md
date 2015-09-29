#PageMagic
PageMagic is an API for testing web applications. 

It has a simple but powerful DSL which makes modelling and interacting with your pages easy.

Wouldn't it be great if there was a framework that could:
- [Model your pages](#modelling-pages)
- [Fluently define interaction hooks / waiters on page elements](#interaction-hooks)
- [Provide urls to pages to avoid awkward page object switching](#page-mapping)
- [Be super dynamic](#dynamic-selectors)

Well PageMagic might just be the answer!

Give it a try and let us know what you think! It's there will undoubtedly be things that can be improved and issues that we are not aware of so your feedback/pull requests are greatly appreciated!

# Installation
`gem install page_magic --pre`

# An Example
Imagine the scene. You've written a web based mail client and now you want to test it...
You have a scenario in mind that goes something along the lines of:
- Send yourself an email with a unique subject
- Go to the Login page and login
- Find the message using it's unique subject and read it
- delete the message

You're mail client is total 21st century so there is loads of lovely ajax etc...

Writing robust, nice looking code for this could be a real pain... 
Here's how you might do it with PageMagic (note that the following code would work if we you had a compatible mail web app but in this case is purely illustrative)

What we really want to write is something like
```ruby
test_subject = send_test_mail('test@21st-century-mail.com')
#Visit your site using a PageMagic session we prepared earlier
session.visit(LoginPage, url: 'https://21st-century-mail.com')

#Login using some handy helper method on our page object
session.login('username', 'password')

#Find the message amongst all the other messages that are on screen and read it
session.message(subject: test_subject).read.click

#Now we are on the message screen lets delete it without having to worry about the ajax.
session.delete_message

fail "message is still there!" if session.message(subject: test_subject).exists?

# Sweet :)
```
## Starting a session
To start a PageMagic session simply decide what browser you want to use and pass it to PageMagic's `.session` method
```ruby
session = PageMagic.session(browser: :chrome)
```
Out of the box, PageMagic knows how to work with:
- Chrome and Firefox
- poltergeist
- RackTest - Read more on testing rack compliant object's directly later on

Under the hood, PageMagic is using [Capybara](https://github.com/jnicklas/capybara) so you can register any Capybara specific driver you want. See below for how to do this.

**Note:** We don't want to impose particular driver versions so PageMagic does not list any as dependencies. Therefore you will need add the requiste gem to your Gemfile.

## Modeling pages
To define something that PageMagic can work with, simply include PageMagic in to a class. Your you will also want to model the elements on your page so that you can interact with them. Here are we are modelling the login page we would need for the example above

```ruby
class LoginPage
  include PageMagic
  text_field(:username, label: 'username')
  text_field(:password, label: 'password')
  button(:login_button, text: 'login')
end
```
In the case of the Login page, it's easy to imagine that it will have text fields for a username and password and a button to login in with.

##Interacting with elements
Elements are defined with a id which is the name of the method you will use to reference it. In the above example, the textfields and button were defined with the id's, `:username`, `:password`, and `:login_button`

After visiting a page with a PageMagic session, you can access all of the elements of that page through the session itself.
```ruby
session.username.set 'joe@blogs.com'
session.password.set 'passw0rd'
session.login_button.click
```

## Defining Pages
To define something that PageMagic can work with, simply include PageMagic in to a class. Here are the classes we would need for the example above.
```ruby
class LoginPage
  include PageMagic
end

class MailBox
  include PageMagic
end

class MessageView
  include PageMagic
end
```

## Helper methods
Using elements that are defined on a page is great, but if you are enacting a procedure through interacting with a few of them then your code could end up with some pretty repetitive code. In this case you can define helper methods instead. 

In the above [example](#an example) we used a helper called `login`.
```ruby
class LoginPage
  # ... code defining elements as shown above
  
  def login(user, pass)
    username.set user
    password.set pass
    login_button.click
  end
end
```

We can interact with helper in the same way as we did page elements.
```ruby
session.login('joe', 'blogs')
```
##Defining sub elements
If your pages are complex you can use PageMagic to compose pages, their elements and subelements to as many levels as you need to.

In the example we accessed a read link that resided with a particular message
```ruby
class MailBox
  include PageMagic
  
  element :message, id: 'message_id' do
    link(:read, text: 'read')
  end
end
```
Sub elements can be accessed through their parent elements e.g:
```
session.message.read.click
```
## Dynamic Selectors
In our scenario we actually selected a message based on a subject that was randomly generated. In this case we would not be able to hard code the selector for our message but instead would need to set the selector dynamically.

```ruby
class MailBox
  include PageMagic
  
  element :message do |subject:|
    selector xpath: '//tr[text()="#{subject}"]' 
    link(:read, text: 'read')
  end
end
```
Here we have defined the 'message' element using a block that takes subject argument. This is passed in at run time and given to the xpath selector.
```ruby
session.message(subject: 'test message')
```
## Interaction hooks
Frequently, you are going to have to work with pages that make heavy use of ajax. This means that just because you've clicked something, it doesn't mean that the action is finished. For these occasions PageMagic provides `before` and `after` hooks that you use to perform custom actions and wait for things to happen. In the case of our web based mail client, we could imagine that when deleting the email, a fancy spinner is displayed whilst the application sends an ajax request to have the message deleted. In this case we wouldn't want to proceed until this has disappeared.

```ruby
class MessagePage
  include PageMagic
  ## code defining other elements, such as subject and body
  
  link(:delete, id: 'delete-message') do
    after do
      wait_until{fancy_animation_has_disappeared?}
    end
  end
end
```
## Page Mapping
You will have noticed that, that we have been performing actions that would move us from page to page but have not done anything to tell PageMagic to use the `MailBox` or `MessagePage`. With PageMagic you can map which pages should be used to handle which URL paths. This is a pretty killer feature that will remove a lot of the juggling and bring back fluency to your code!
```ruby
# define what pages map to what
browser.define_page_mappings %r{/messages/\d+} => MessagePage,
                             '/login' => LoginPage,
                             '/' => MailBox
```
You can use even use regular expressions to map multiple paths to the same page. In the above example we are mapping paths that that starts with '/messages/' and are followed by one ore more digits to the `MessagePage` class.

##What else can you do with PageMagic?
PageMagic has lots of other useful features. I'm writing up the documentation so check back here soon!

