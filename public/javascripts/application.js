jQuery(function ($) {
    var csrf_token = $('meta[name=csrf-token]').attr('content'),
        csrf_param = $('meta[name=csrf-param]').attr('content');
    
    $('select[data-url]').live('change', function (e){
        var node = $(this),
            url = node.attr('data-url'),
            method = node.attr('data-method'),
            form = $('<form method="post" action="'+url+'">'),
            metadata_input = '<input name="_method" value="'+method+'" type="hidden" />';

        if (csrf_param != null && csrf_token != null) {
          metadata_input += '<input name="'+csrf_param+'" value="'+csrf_token+'" type="hidden" />';
        }

        form.hide()
            .append(metadata_input)
            .append(node)
            .appendTo('body');

        e.preventDefault();
        form.submit();
    });
    
    $(".sortable").sortable({
      update:function(event, ui) {
          $.ajax({
            url: $(this).attr('data-url'),
            data: $(this).sortable('serialize'),
            type: "POST"
            });
        }
      });
    $(".sortable").disableSelection();
});
