# This script makes sure that clicking on a link within a dropdown menu
# closes the dropdown menu, even if the request takes some time.
#
ready = ->
  $(document).on('click', '.dropdown-menu * a', (event) ->
    $(this).closest('.btn-group').removeClass("open")
    
    if $(this).closest('.btn-group').hasClass("group_export")
      # The download is started by the browser in parallel. There is no
      # need to deactivate the button.
    else
      btn = $(this).closest('.btn-group').find('.btn.dropdown-toggle')
      btn.attr('data-loading-text', "<i class='icon-spinner icon-spin'></i> " + btn.text().trim() + " ...")
      btn.button("loading") # http://stackoverflow.com/questions/14793367/
  )

$(document).ready(ready)
$(document).on('page:load', ready)
