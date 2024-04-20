# Rails Hotwire Sandbox
A place for me to toy around a bit with Rails hotwire after learning the basics.

## Recap
- What is hotwire?
Hotwire is an approach to building web applications by sending HTML instead of JSON over the wire
- An umbrella term for three frameworks, Turbo, Stimulus and Strada

### Turbo Drive
- Speeds up RoR applications by converting all link clicks and form submissions into AJAX requests.
- When Turbo Drives receives the response, it replaces the `<body>` of the current page with the `<body>` of the response, leaving `<head>` unchanged in most cases
- Gets installed by default in Rails 7 applications.
- To disable Turbo Drive on links/submit, add `data-turbo="false"` or `data: {turbo: false}` if on link/submit rails tag
- To disable Turbo Drive on whole application, add `Turbo.session.drive = false` on `app/javascript/application.js`
- With `data-turbo-track="reload"`, Turbo Drive knows how to compare the `<head>` in both current page and response, and if there is any differences, reload the page.

### Turbo Frames
- Turbo frames let us predefine a portion of our page to be replaced during any request.
- To connect turbo frames, wrap a portion with `turbo_frame_tag`:
```erb
<%= turbo_frame_tag list do %>
  <h1 class='text-2xl'><%= link_to list.name, list_path(list), data: {turbo_frame: "_top"} %></h1>

  <%= link_to 'Edit list name', edit_list_path(list)%>
<% end %>
```
and connect with other of the same tag
```
<%= turbo_frame_tag @list do %>
  <%= render 'form', list: @list %>
<% end %>
```
- **3 Rules:**
  1. When clicking a link within a Turbo Frame, Turbo expects a frame of the **same id** on the target page. It will then replace the frame's content on the source page with the frame's content on the target page.
  2. When clicking on a link within a Turbo Frame, if no matching turbo frame ID found, it will return `error Response has no matching <turbo-frame id="name_of_the_frame"> element` is logged to the console.
  3. A link can target a Turbo Frame that is not directly nested in. Using `data: {turbo_frame: dom_id}` you can set a Turbo Frame with the same ID that's supplied to `data-turbo-frame` and it will be replaced by the target turbo frame once the link is clicked
- If you have a link in a turbo frame that just want to act normally like a page navigation, use `data: {turbo_frame: "_top"}`
- Providing `src` will populate the target frame after the initial page load by making a separate request to the associated path.
- To make frames lazy load, add `loading: "lazy"` where the frame will only fetch the content once it becomes visible on the page.

### Turbo Stream
- Turbo Stream send page changes as HTML wrapped in `<turbo-stream>` elements. 
- Turbo Stream specify an action to perform and the target ID of the DOM element to update with the action.
- Streams can be sent in response to either a direct browser request, or websocket connection. Turbo streams are delivered by user of our controller.
- 7 actions: `append`, `prepend`, `before`, `after`, `replace`, `update`, `remove`
- To tell controller we want to accept a turbo stream format:
```ruby
respond_to do |format|
  format.turbo_stream
end
```
- `respond_to do |format|` block is a way of telling controller to do more than just `html` format requests.
- To chain multiple `turbo_stream` actions, place it in the `turbo_stream.erb` file with the corresponding controller method, like `create.turbo_stream.erb`, `destroy.turbo_stream.erb` etc.
- If it is just only one turbo action, you can place it directly on the `respond_to` format block ie:
```ruby
format.turbo_stream { render turbo_stream: turbo_stream.prepend 'lists', @list}
```
- Do not chain multiple turbo actions in the controller file itself.
- The response from `create.turbo_stream.erb`:
```html
# This performs a prepend action where the HTML of the new list is prepended to a tag of dom_id 'lists'
<turbo-stream action="prepend" target="lists"><template><turbo-frame id="whole_list_861275402">
  <div class='my-8 mx-5 border-solid border-2 p-2 border-black'>
    <turbo-frame id="list_861275402">
      <h1 class='text-2xl'><a data-turbo-frame="_top" href="/lists/861275402">new lists 5</a></h1>

      <a href="/lists/861275402/edit">Edit list name</a>
</turbo-frame>
    <form class="button_to" method="post" action="/lists/861275402"><input type="hidden" name="_method" value="delete" autocomplete="off" /><button type="submit">Remove list</button><input type="hidden" name="authenticity_token" value="B4mxRlUMq6EwaDAtX28pj2OI_ZKPWpVSdjMVfpCcCKLTcNyZ3TcbOz0yxhkdfXqXNyxHQ-AWuR2NWIUOrBG_lg" autocomplete="off" /></form>

    <ul>
    </ul>
  </div>
</turbo-frame></template></turbo-stream>

# This updates the content of the frame tag 'new_list' to be empty
<turbo-stream action="update" target="new_list"><template></template></turbo-stream>

# This prepend a flash HTML to the id target 'flash'
<turbo-stream action="prepend" target="flash"><template>  <p>List successfully created.</p>
</template></turbo-stream>
```
