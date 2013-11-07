# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
    window.images = {}
    window.ids = {}
    r_down = false
    l_down = false
    mouse_x = 0
    mouse_y = 0
    mirrored = false

    rcanvas = $("#right_leg")[0]
    c_width = rcanvas.width
    c_height = rcanvas.height

    r_context = rcanvas.getContext('2d')
    l_context = $('#left_leg')[0].getContext('2d')

    bind_listeners = ->
        $('#left_cover_canvas').mousedown(left_down)
        $('#left_cover_canvas').mousemove(left_move)
        $('#left_cover_canvas').mouseup(left_up)

        $('#right_cover_canvas').mousedown(right_down)
        $('#right_cover_canvas').mousemove(right_move)
        $('#right_cover_canvas').mouseup(right_up)

        $('#mirror').change(mirror_image)

    mouse_up = () ->
        console.log('up')
        mouse_x = 0
        mouse_y = 0

    right_down = ->
        r_down = true

    right_up = ->
        r_down = false
        mouse_up()

    left_down = ->
        l_down = true

    left_up = ->
        l_down = false
        mouse_up()

    r_image = {
        origin: {
            x: 5,
            y: 5
        }
        width: c_width - 10,
        height: c_height - 10
    }

    l_image = {
        origin: {
            x: 5,
            y: 5
        }
        width: c_width - 10,
        height: c_height - 10
    }

    get_diffs = (event) ->
        diffs = [0, 0]

        if r_down || l_down
            mouse_x = event.pageX if mouse_x == 0
            mouse_y = event.pageY if mouse_y == 0

            diffs[0] = mouse_x - event.pageX
            diffs[1] = mouse_y - event.pageY

        mouse_x = event.pageX
        mouse_y = event.pageY

        diffs

    draw_right_image = ->
        r_context.clearRect(0, 0, c_width, c_height)
        r_context.drawImage(window.images.right, r_image.origin.x, r_image.origin.y, r_image.width, r_image.height)

    move_right_image = (diffs) ->
        r_image.origin.x -= diffs[0]
        r_image.origin.y -= diffs[1]
        draw_right_image()

    right_move = (event) ->
        diffs = get_diffs(event)
        if r_down && window.images.right != undefined
            move_right_image(diffs)
            if mirrored
                move_left_image(diffs)

    draw_left_image = ->
        l_context.clearRect(0, 0, c_width, c_height)
        l_context.drawImage(window.images.left, l_image.origin.x, l_image.origin.y, l_image.width, l_image.height)

    move_left_image = (diffs) ->
        l_image.origin.x -= diffs[0]
        l_image.origin.y -= diffs[1]
        draw_left_image()

    left_move = (event) ->
        diffs = get_diffs(event)
        if l_down && window.images.left != undefined
            move_left_image(diffs)
            if mirrored
                move_right_image(diffs)

    mirror_image = ->
        left_image = window.images.left != undefined

        if left_image
            context = r_context
            image = window.images.left
            window.images.right = image
            r_image = l_image
        else
            context = l_context
            image = window.images.right
            window.images.left = image
            l_image = r_image

        if $(this).is(':checked')
            mirrored = true
            context.translate(c_width, 0)
            context.scale(-1, 1)
        else
            mirrored = false
            context.translate(0, 0)
            context.scale(-1, 1)

        draw_left_image()
        draw_right_image()

    bind_listeners()

    window.add_leg = (leg, source) ->
        # remove option from dropdown and show mirror checkbox
        $("#leg option[value='#{leg}']").remove()
        # $('#mirror_option').show()

        # clear artwork name text box
        $('#artwork_name').val('')

        # add image to canvas
        canvas = $("##{leg}_leg")[0]
        context = canvas.getContext('2d')
        img = new Image()

        img.onload = ->
            context.drawImage(img, 5, 5, c_width - 10, c_height - 10)

        img.src = source
        window.images[leg] = img

    fill_in_form = (form, data) ->
        form.find('#transform_image_x').val(data.origin.x)
        form.find('#transform_image_y').val(data.origin.y)
        form.find('#transform_width').val(data.width)
        form.find('#transform_height').val(data.height)
        form.find('#transform_leg').val(data.leg)
        form.find('#transform_mirror')
        form.find('#transform_artwork_id').val(data.artwork_id)
        form.find('#transform_design_id').val(data.design_id)
        form.find('#transform_rotation')
        form.submit()

    window.design_created = (design_id) ->
        if mirrored # populate one form and make sure mirror is checked there!
            0
        else # populate both forms
            right = $('#right_transform')
            r_image.leg = "right"
            r_image.artwork_id = window.ids['right']
            r_image.design_id = design_id
            fill_in_form(right, r_image)

            left = $('#left_transform')
            l_image.leg = "left"
            l_image.artwork_id = window.ids['left']
            l_image.design_id = design_id
            fill_in_form(left, l_image)
