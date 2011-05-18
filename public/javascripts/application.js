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
$('.item .head').live("dblclick", function () {
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
    item.find(".title").html(data.title);
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
$('.filter a.new').live("click", function(event, data, status, xhr) {
    $(".filter .label.new").find("div.toggle").toggle();
});
// toggle label form
$('.label a.toggle').live("click", function(event, data, status, xhr) {
    $(this).parents(".label").find("div.toggle").toggle();
});
// color-picker
$('.color-picker .options .color').live("click", function (event, data, status, xhr) {
    // http://stackoverflow.com/questions/1740700/get-hex-value-rather-than-rgb-value-using-jquery#answer-3971432
    function rgb2hex(rgb) {
      rgb = rgb.match(/^rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*(\d+))?\)$/);
      function hex(x) {
        return ("0" + parseInt(x).toString(16)).slice(-2);
      }
      return hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
    }
    var color = rgb2hex($(this).css("background-color"));
    var input = $(this).parents("form").find("input.color")[0];
    input.value = color;
    //$(this).parents("form").find(".color.result").css("background-color", "#" + color);
    $('.label form input.color').change();
});
$('.label form input.color').live("change", function (event, data, status, xhr) {
    var input = $(this).parents("form").find("input.color")[0];
    var color = input.value;
    $(this).parents("form").find(".color.result").css("background-color", "#" + color);
});
// label created
$('form.new_label').live("ajax:success", function(event, data, status, xhr) {
    $('.filter .labels').prepend(data.label);
    $.each(data.item_labels, function (item_id, node) {
      $('#item_' + item_id + ' .labels').prepend(node);
    });
    // reset form
    this.reset();
    $('.label form input.color').change();
    $('.filter a.new').click();
});
// label updated
$('form.edit_label').live("ajax:success", function(event, data, status, xhr) {
    $(this).parents(".label").replaceWith(data.label);
    $.each(data.item_labels, function (item_id, node) {
      $('#item_' + item_id + ' .labels .label_' + data.label_id).replaceWith(node);
    });
});
// delete label
$('.label a.delete').live("ajax:success", function (event, data, status, xhr) {
    var label = $(this).parents(".label");
    label.remove();
    $(".item ." + label[0].id).remove();
});

// apply/cancel label filter for items
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
      $('.item:has(.' + label.id + '.attached)').show();
    }
});

// manage item labels
$('.item .manage-labels').live("dblclick", function (event, data, status, xhr) {
    event.stopPropagation(); // don't open item
});
$('.item .manage-labels').live("click", function (event, data, status, xhr) {
    $(this).parents(".item").find(".labels").toggleClass("managing");
    event.stopPropagation(); // don't open item
});
$('body').live("click", function (event, data, status, xhr) {
    $(".item .labels.managing").removeClass("managing");
});
// attach / detach item labels
$('.item .labels.managing .label').live("click", function (event, data, status, xhr) {
    var attached = $(this).is(".attached");
    if (attached) {
      $(this).find("a.detach").click();
    } else {
      $(this).find("a.attach").click();
    }
    $(this).toggleClass("attached");
    event.stopPropagation();
});
