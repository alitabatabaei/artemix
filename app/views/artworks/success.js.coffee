window.ids["<%= @leg %>"] = <%= @artwork.id %>
window.add_leg("<%= @leg %>", "<%= @artwork.image.url(:canvas) %>")
window.original_leg = "<%= @leg %>"
btn = $('#upload')
btn.attr('disabled', false)
btn.val('Upload Image')