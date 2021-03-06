jQuery(function ($) {
    $(".sortable").sortable({
      axis: 'y',
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

// new item
$('form.new_item').live("ajax:success", function(event, data, status, xhr) {
    $('.items').prepend(data);
    this.reset();
});

// open/close item
$('.item .title').live("dblclick", function () {
    $(this).parent().children(".edit").toggle();
});

// autosave item
$('.item textarea').live('focus', function(e) {
  // TODO: keep md5 or some kind of hash value instead of whole text.
  $(this).data("lastValue", this.value);
});
$('.item textarea').live('keyup', function(e) {
  var lastValue = $(this).data("lastValue");
  if (lastValue !== this.value) {
    var form = $(this).parents("form");
    // Yakitara.updateFormObserver(form, function () {
    //   form.submit();
    // });
    var interval = 3000; //form.attr("data-autosave-interval");
    var lastTimeoutId = form.data("TimeoutId");
    if (lastTimeoutId) {
      clearTimeout(lastTimeoutId);
    }
    
    // form.data("TimeoutId", setTimeout(function () { alert("autosave!"); }, interval));
    form.data("TimeoutId", setTimeout(function () {
      form.submit();
    }, interval));
    
    $(this).parents(".item").children(".changed").fadeIn();
    // var dataChangeQuery = form.attr("data-change-query");
    // if (dataChangeQuery) {
    //   DataQuery.processQueries(form, dataChangeQuery, $(this).value);
    // }
  }
  $(this).data("lastValue", this.value);
});
$('.item form.edit_item').live("ajax:success", function (event, data, status, xhr) {
    var item = $(this).parents(".item");
    item.children(".changed").fadeOut();
    item.children(".title").html(data.title);
    item.find(".attributes").html(data.attributes);
});

// click to ".selected"
$('.item').live("click", function () {
    $('.item').removeClass("selected");
    $(this).addClass("selected");
});

// done item
$('.item form.done_item').live("ajax:success", function (event, data, status, xhr) {
    $(this).parents(".item").remove();
});

// undone item
$('.item .undone_item').live("ajax:success", function(event, data, status, xhr) {
    $(this).parents(".item").remove();
});

// move item
$('.item form.move_item select').live('change', function (event) {
    $(this).parents(".item").find("input").attr("disabled", "disabled");
    $(this).parents("form").submit();
});
$('.item form.move_item').live("ajax:success", function (event, data, status, xhr) {
    var src_list_id = Number($(this).parents(".list")[0].id.match(/list_(\d+)/)[1]);
    if (data.list_id !== src_list_id) {
      $(this).parents(".item").remove();
    }
});
