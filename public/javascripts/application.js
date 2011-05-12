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

// new label
$('form.new_label').live("ajax:success", function(event, data, status, xhr) {
    $('.filter .labels').prepend(data);
    this.reset();
});
// delete label
$('.label .delete a').live("ajax:success", function (event, data, status, xhr) {
    $(this).parents(".label").remove();
});
// toggle item menu
$('.item .menu-switch').live("click", function (event, data, status, xhr) {
    $(this).parents(".item").find(".menu").children().toggleClass("selected");
});

// assign label to item
$('.label.assign a').live("ajax:success", function (event, data, status, xhr) {
    $(this).parents(".item").find(".labels").prepend(data);
});
// unassign label to item
$('.label.unassign a').live("ajax:success", function (event, data, status, xhr) {
    var dom_class = "label_" + data.label_id;
    $(this).parents(".item").find(".labels ." + dom_class).remove();
});

// toggle filter items by label
$('.filter .label a').live("click", function (event, data, status, xhr) {
    $(".filter .label").removeClass("selected");
    var current = decodeURI(document.location.hash);
    var label = $(this).parents(".label")[0];
    if (current === decodeURI(this.hash)) {
      // cancel label
      $('.item').show();
      document.location.hash = "";
      event.preventDefault();
    } else {        
      // apply label
      $(label).addClass("selected");
      $('.item').hide();
      $('.item:has(.' + label.id + ')').show();
    }
});

// color-picker
$('body').live("click", function (event, data, status, xhr) {
    $(".color-picker .options").hide();
});
$('.color-picker').live("click", function (event, data, status, xhr) {
    event.stopPropagation();
});
$('.color-picker .switch').live("click", function (event, data, status, xhr) {
    $(this).parents(".color-picker").find(".options").toggle();
    // var options = $(this).parents(".color-picker").find(".options");
    // if (options.is(":hidden")) {
    // } else {
    // }
});
$('.color-picker .options .color').live("click", function (event, data, status, xhr) {
    // http://stackoverflow.com/questions/1740700/get-hex-value-rather-than-rgb-value-using-jquery#answer-3971432
    function rgb2hex(rgb) {
      rgb = rgb.match(/^rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*(\d+))?\)$/);
      function hex(x) {
        return ("0" + parseInt(x).toString(16)).slice(-2);
      }
      return hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
    }
    var input = $(this).parents(".options").find("input")[0];
    input.value = rgb2hex($(this).css("background-color"));
});
$('.color-picker button.ok').live("click", function (event, data, status, xhr) {
    var color = $(".color-picker input")[0].value;
    $("form.new_label input.color")[0].value = color;
    $(this).parents(".color-picker").find(".switch").css("background-color", "#" + color);
    $(".color-picker .options").hide();
});
jQuery(function ($) {
    var input = $("form.new_label input.color")[0];
    if (input) {
      $(".color-picker input")[0].value = input.value;
    }
});
