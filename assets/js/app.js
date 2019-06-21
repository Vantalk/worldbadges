// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"


// -------------------------- Bootstrap js/jquery setup -----------------------
global.$ = global.jQuery = require("jquery")
global.bootstrap = require("bootstrap")
global.bootstrap = require("textarea-autosize")

// prevent # link
$(document).on('click', 'a[href="#"]', function(event) {
  event.preventDefault()
})

$(document).ready(() => {
  $('[data-toggle="tooltip"]').tooltip(); $('[data-toggle="popover"]').popover();
  // $('textarea.js-auto-size').textareaAutoSize();
  // let x = $('#content').height()
  // $('#content').height( x - 35 );
  // $('.sidebar_right').height( x - 35 );
  // global.vh = document.documentElement.clientHeight
  if (window.opened_article) toggle_events_panel()
  loadingResults = false
})

// ------------------------------- main.js setup ------------------------------
import Main from './main'

// create socket
import {Socket} from 'phoenix'
if(user_id != '') {
  let socket = new Socket('/socket', {params: {guardian_token: window.guardian_token}})

  // connect to channels
  let main = new Main(socket)
  main.initialize(page_name)

  window.onbeforeunload = function(){
    main.persona_room.push('update_left_at')
  };

  global.post_notif_nr = 0;
  global.chat_notif_nr = 0;
  global.search_ids    = [];


  global.addPersonaToContacts = function (object, id, action) {
    object.innerHTML = 'Pending';
    main.persona_room.push('add_persona_to_contacts', {id: id, action: action})
  }

  global.searchNonMembers = function (object, id, action) {
    let input     = document.getElementById('non-mb-search').value
    let page_name = document.getElementById('pb-title').innerText
    main.persona_room.push('search_non_members', {input: input, page_name: page_name})
  }

  global.personaToPageAction = function (action, object, page_name, persona_id) {
    if (!persona_id) {persona_id = '0'}

    switch (action) {
      case 'invite':
        object.className = 'btn btn-sm btn-success'
        object.innerText = "Invited"
        incrementElement('mb-count-invited')
        break;
      case 'revoke_invite':
        object.parentElement.remove()
        decrementElement('mb-count-invited')
        break;
      case 'accept_join':
        object.parentElement.remove()
        incrementElement('mb-count-members')
        decrementElement('mb-count-waiting')
        break;
      case 'reject_join':
        object.parentElement.remove()
        decrementElement('mb-count-waiting')
        break;
      case 'kick':
        object.parentElement.remove()
        decrementElement('mb-count-members')
        break;
    }

    main.persona_room.push('persona_to_page_action', {action: action, page_name: page_name, persona_id: persona_id})
  }

  // global.contactsToggle = function (object) {
  //   let page_name = object.id.replace('btn_','');
  //
  //   if (object.dataset.active == "false") {
  //     main.persona_room.push('get_page_members', {page_name: page_name, presences: presences});
  //     object.dataset.active = "active";
  //   }
  //   let group = document.getElementById('page-groups').getElementsByClassName('show')[0]
  //   if (group && group.id != 'contacts_'+page_name) {group.classList.remove('show')}
  //   document.getElementById('contacts_'+page_name).classList.toggle('show');
  // }

  global.pageBoxToggle = function (object) {
    let page_box = document.getElementById('page-box');
    let title    = document.getElementById('pb-title');
    let buttons  = document.getElementById('page-box-buttons');
    let visible  = document.getElementById('page-box-visible');
    let log_time = document.getElementById('log-time-pb');
    let pg_name  = "";

    if (object) {pg_name = object.id.replace('btn_','').replace(/_/g, ' ')}
    else if (personal_page) {pg_name = 'Your page'}
    else if (page_name) {pg_name = page_name}

    if (title.innerText == pg_name) {page_box.hidden = !page_box.hidden}
    else {
      if (['&#8734;', '∞'].indexOf(log_time.innerText) > -1) {log_time.innerText = "1 day"}
      page_box.hidden = false;
      title.innerText = pg_name;
      if (pg_name == 'Your page') {buttons.hidden = true; visible.hidden = false}
      else {
        buttons.hidden = false; visible.hidden = true;
        main.persona_room.push('get_page_members', {page_name: pg_name, presences: presences})
      }
    }
  }

  global.eventsBoxToggle = function (type, persona_id) {
    let eventsBox = document.getElementById('events-box')
    let class_hidden = eventsBox.classList.contains('chat-opened')

    if (type != eventsBox.dataset.type) {
      if (type == "chat") {document.getElementById('events-posting-list').hidden = true}
      else {document.getElementById('events-chat-list').hidden = true}
      document.getElementById(`events-${type}-list`).hidden = false

      eventsBox.hidden = false
      eventsBox.dataset.type = type
      showMissedEvents(type, persona_id)
    } else if (!class_hidden) {eventsBox.hidden = !eventsBox.hidden}

    eventsBox.classList.remove('chat-opened')
  }

  global.showMissedEvents = function (category, persona_id) {
    main.persona_room.push(category+':get_events', {persona_id: persona_id});
  }

  global.showBoxData = function (type) {
    switch (type) {
      case 'contacts':
        main.persona_room.push('show_box_contacts', {presences: presences});
        break;
      case 'pages':
        main.persona_room.push('show_box_pages', {presences: presences});
        break;
    }
  }

  global.showBoxContacts = function () {
    main.persona_room.push('show_box_pages', {presences: presences});
  }

  global.editAction = function (edit, id) {
    let upload = document.getElementById('edit_upload_'+id)
    let parent = upload.parentElement
    if (edit) {
      let data = {elem_id: parent.nextElementSibling.id, content: parent.children[0].value}

      if (upload.files[0]) {
        let uploaded_file = upload.files[0]
        let reader = new FileReader();
        reader.onloadend = function () {
          data["upload"] = {encoding: reader.result, name: uploaded_file.name, type: uploaded_file.type}
          main.persona_room.push('edit', data)
          parent.remove()
        }
        reader.readAsDataURL(uploaded_file);
      } else {
        main.persona_room.push('edit', data)
        parent.remove()
      }

    } else { parent.nextElementSibling.hidden = false; parent.remove() }
  }

  global.loadingResults = true
  global.loadMore = function (object, type) {
    if (loadingResults) {return}
    let scroll_forward  = !(["false", undefined, "undefined"].indexOf(object.dataset.scrollForward)  > -1)
    let scroll_backward = !(["false", undefined, "undefined"].indexOf(object.dataset.scrollBackward) > -1)
    let direction = null;

    if (scroll_forward && object.scrollTop == object.scrollTopMax) {console.log("FWD"); direction = "fwd"}
    else if (scroll_backward && object.scrollTop == 0) {console.log("BWD"); direction = "bwd"}

    if (direction) {
      loadingResults = !loadingResults
      main.persona_room.push('load_more', {elem_id: object.id, dataset: object.dataset, direction: direction, scroll_top: object.scrollTop, type: type})
    }
  }

  // global.switchWContacts = function (object = undefined) {
  //   // if (chatPids.length != 0) {showWriteBox('personas')}
  //   // let chat_icon = document.getElementById('chat-icon');
  //   // if (object == undefined || (object != undefined && chat_icon.className == "fa fa-comments")) {
  //   //   chat_icon.className = "fa fa-comments-o";
  //     main.persona_room.push('show_writebox_contacts', {presences: presences});
  //   // }
  //   // document.getElementById('list_of_contacts').className = "";
  //   // document.getElementById('pages_list').className = "hidden";
  //
  //   // chatPids = [];
  // }

  global.selectWObject = function (type, name = "", id = "") {
    let writeBox = document.getElementById('write-box')
    let title = document.getElementById('write-title')
    let pagesList = document.getElementById('write-page-list')
    let contactsList = document.getElementById('write-contact-list')
    let visible = document.getElementById('write-visible').parentElement.parentElement;
    writeBox.dataset.type = type;

    if (type == 'message') {
      pagesList.hidden = true; contactsList.hidden = false;

      title.innerText = "Write message to "+name;
      writeBox.dataset.id = id;
    } else {
      document.getElementById('write-messages').innerHTML = "";
      pagesList.hidden = false; contactsList.hidden = true;

      if (type == 'persona_article') {title.innerText = 'Write article for My page';}
      // else if (type == 'comment') {title.innerText = 'Write comment for opened article';}
      else {
        title.innerText = 'Write article for '+name;
        writeBox.dataset.id = name;
      }
    }

    if (type == 'persona_article') {visible.hidden = false;}
    else {visible.hidden = true;}
  }

  global.sendReport = function () {
    let modal = document.getElementById('report-modal')
    let case_type = modal.querySelector("input[name='case[type]']:checked").value;
    let case_details = modal.querySelector("[name='case[details]']").value;
    main.persona_room.push('report', {case_type: case_type, details: case_details, id: modal.dataset.id, type: modal.dataset.type});
    popMessage("Thank you for helping us keep our website clean! Your report was sent.", "info")
  }

  global.sendMessage = function (object, id) {
    let textarea = object.previousElementSibling;
    let log_time = document.getElementById('log-time-'+id).innerText;

    main.persona_room.push('chat:message_create', {content: textarea.value, recipient_id: textarea.dataset.recipient, group_chat: textarea.dataset.groupChat, log_time: log_time});
    textarea.value = "";
    textarea.focus()
  }

  global.writeArticle = function () {
    let textarea = document.getElementById('pb-textarea')
    let log_time = document.getElementById('log-time-pb')
    let visible  = document.getElementById('page-box-visible')

    let data = {content: textarea.value, log_time: log_time.innerText}

    let article_type = ""
    if (visible.hidden) {
      article_type = "page_article"
      data["obj_id"] = document.getElementById('pb-title').innerText
      data["visibility"] = document.getElementById('pb-visible').innerText
    } else {article_type = "persona_article"}

    let upload = document.getElementById('pb-upload')

    if (upload.dataset.empty == "true") {
      data["upload"] = null
      main.persona_room.push(`posting:${article_type}_create`, data)
    } else {
      let uploaded_file = upload.files[0]
      let reader = new FileReader();
      reader.onloadend = function () {
        data["upload"] = {encoding: reader.result, name: uploaded_file.name, type: uploaded_file.type}
        main.persona_room.push(`posting:${article_type}_create`, data)
        toggleUploadLabel(true)
      }

      reader.readAsDataURL(uploaded_file);
    }

    textarea.value = ""
    textarea.focus()
  }

  // global.writeObject = function () {
  //   let writeBox = document.getElementById('write-box')
  //   let obj_type = writeBox.dataset.type
  //   let obj_id   = writeBox.dataset.id //id or name
  //   let textarea = document.getElementById('write-textarea')
  //   let log_time = document.getElementById('log-time-write')
  //
  //   if(obj_type == "message") {
  //     main.persona_room.push('chat:message_create', {content: textarea.value, recipient_id: obj_id, group_chat: "false", log_time: log_time.innerText});
  //   }
  //   // else if (obj_type == "comment") {
  //   //   main.persona_room.push('posting:comment_create', {content: textarea.value, obj_id: window.opened_article})
  //   // }
  //   else {
  //     let data = {content: textarea.value, log_time: log_time.innerText}
  //     if (obj_type == "persona_article") {data["visibility"] = document.getElementById('write-visible').innerText}
  //     else if (obj_type == "page_article") {data["obj_id"] = obj_id}
  //
  //     let article_upload = document.getElementById('article-upload')
  //
  //     if (article_upload.dataset.empty == "true") {
  //       data["upload"] = null
  //       main.persona_room.push(`posting:${obj_type}_create`, data)
  //     } else {
  //       let uploaded_file = article_upload.files[0]
  //       let reader = new FileReader();
  //       reader.onloadend = function () {
  //         data["upload"] = {encoding: reader.result, name: uploaded_file.name, type: uploaded_file.type}
  //         main.persona_room.push(`posting:${obj_type}_create`, data)
  //         toggleUploadLabel(true)
  //       }
  //
  //       reader.readAsDataURL(uploaded_file);
  //     }
  //   }
  //
  //   textarea.value = ""
  //   textarea.focus()
  // }

  global.scrollSideList = function (object) {
    let parent = object.parentElement.parentElement
    let offset = Number(document.getElementById('side-search').dataset.offset)
    let type = document.getElementById('side-search-input').dataset.type
    if (object.innerHTML == "Back" && offset > 0) {
      offset -= 3
    } else if (object.innerHTML == "Next") {
      offset += 3
    }

    main.persona_room.push('scroll_side_list', {offset: offset, search_ids: search_ids, type: type, presences: presences})
  }

  global.sideSearch = function (event) {
    var input  = document.getElementById('side-search-input')
    var button = document.getElementById('side-search-btn')
    var type   = input.dataset.type

    if (event == "default") {
      document.getElementById('side-search').dataset.offset = "0";
      main.persona_room.push('side_search', {input: "default", type: type, presences: presences})
    } else if (event.type == "click") {
      if (input.value.trim() == '') {
        main.persona_room.push('side_search', {input: "default", type: type, presences: presences})
        toggleSideSearch();
      } else {
        button.innerHTML = "<i class='fa fa-times' aria-hidden='true'></i>"
        main.persona_room.push('side_search', {input: input.value, type: type, presences: presences})
        input.value = ''
      }
    } else {
      if (input.value.trim() == '') {
        button.innerHTML = "<i class='fa fa-times' aria-hidden='true'></i>"
      } else if (event.keyCode == 13) {
        button.innerHTML = "<i class='fa fa-times' aria-hidden='true'></i>"
        main.persona_room.push('side_search', {input: input.value, type: type, presences: presences});
        input.value = ''
      } else {button.innerHTML = "Go"}
    }
  }
}

global.hideElements   = function (array) {for (var i = 0; i < array.length; i++) {document.getElementById(array[i]).hidden = true}}
global.showElements   = function (array) {for (var i = 0; i < array.length; i++) {document.getElementById(array[i]).hidden = false}}
global.toggleElements = function (array) {for (var i = 0; i < array.length; i++) {let y = document.getElementById(array[i]); y.hidden=!y.hidden}}

global.addClass    = function (array, clas) {for (var i = 0; i < array.length; i++) {document.getElementById(array[i]).classList.add(clas)}}
global.removeClass = function (array, clas) {for (var i = 0; i < array.length; i++) {document.getElementById(array[i]).classList.remove(clas)}}
global.toggleClass = function (array, clas) {for (var i = 0; i < array.length; i++) {document.getElementById(array[i]).classList.toggle(clas)}}

// ----------------------------- global functions -----------------------------
global.toggle_events_panel = function () {
  // var ad             = document.getElementById('ad')
  var comments_panel = document.getElementById('comments_panel')
  var events_panel   = document.getElementById('events_panel')
  let comments       = document.getElementById('comments')

  // ad.hidden = !ad.hidden
  comments_panel.hidden = !comments_panel.hidden
  events_panel.hidden = !events_panel.hidden
  window.events_panel = !window.events_panel
  document.getElementById(window.opened_article).classList.toggle("opened_article")
  if (!window.location.hash || page_name == "") comments.scrollTop = comments.scrollTopMax
  // window.opened_article = undefined;
  // document.getElementById('write-comment').hidden = true;
}

global.currentChat = null;
global.moveChat = function (object) {
  currentChat = object.parentElement
  document.onmousemove = function(e) {
    currentChat.style.top = (e.y - 5)+"px";
    currentChat.style.left = (e.x - 5)+"px";
  }
}

global.closeChat = function (object, id) {
  // TODO: remove chat id from cookie/store
  object.parentElement.parentElement.parentElement.remove()

  // Find and remove item from an array
  var i = openedChatPids.indexOf(id);
  if(i != -1) {
  	openedChatPids.splice(i, 1);
  }
}

global.moveBox = function (object) {
  parent = object.parentElement;
  document.onmousemove = function(e) {
    parent.style.top = (e.y - 5)+"px";
    parent.style.left = (e.x - 5)+"px";
  }
}

// TODO: can move to comments partial
global.commentsTextareaScrollHeight = null;
global.resizeCommentsTextarea = function (textarea) {
  var comments = document.getElementById('comments')
  var comments_height = ((comments.style.height == "") ? vh * 0.65 : parseFloat(comments.style.height));
  var diff = commentsTextareaScrollHeight - textarea.scrollHeight

  if (commentsTextareaScrollHeight != textarea.scrollHeight && (diff > 0 || comments_height > 150)) {
    textarea.style.overflow = "hidden"
    textarea.style.height = 0;
    textarea.style.height = textarea.scrollHeight + 'px';
    diff = commentsTextareaScrollHeight - textarea.scrollHeight // this needs to be calculated again here because first calculation is faulty on diff > 0. leave as it is

    comments.style.height = comments_height + diff + "px"
    comments.scrollBy(0, -diff)

    commentsTextareaScrollHeight = textarea.scrollHeight
  } else if (comments_height <= 150 && diff < 0) {
    textarea.style.overflow = "auto"
  }
}

global.wCategory = null;
global.showWriteBox = function (category, value = '') {
  let writeBox = document.getElementById('write-box');

  if (value == 'toggleWriteBox') {
    // if article or (no article && wCategory) -> just toggle
    // if(window.opened_article || wCategory) {writeBox.hidden = !writeBox.hidden; return}
    if(wCategory) {writeBox.hidden = !writeBox.hidden; return}
    else value = '';
  }

  let writeTitle = document.getElementById('write-title');
  let urlArray = document.location.href.split('/')
  let page_type = urlArray[3]
  let page_name = urlArray[4]
  writeBox.hidden = false;

  if (category) {wCategory = category} else {wCategory = "pages"}

  if (wCategory == 'pages') {

    if (page_type == 'persona' || page_type == '' || !subdPage(page_name)) {
      writeTitle.innerText = "Write article for My page";
      writeBox.dataset.type = 'persona_article';
      document.getElementById('write-visible').parentElement.parentElement.hidden = false;
    } else if (page_type == 'page' && page_name != 'new') {
      writeTitle.innerText = 'Write article for '+page_name.replace(/_/g, ' ');
      writeBox.dataset.type = 'page_article'; writeBox.dataset.id = page_name;
      document.getElementById('write-visible').parentElement.parentElement.hidden = true;
    }
  } else {
    // TODO: writeBox.dataset.id = contact.id
    writeBox.dataset.type = "message";
  }

  let textarea = writeBox.getElementsByTagName('textarea')[0];
  textarea.value = value;
  textarea.focus();
  resizeWriteBox();
}

global.resizeWriteBox = function () {
  document.getElementById('write-list').style.height = document.getElementById('write-text').clientHeight + 'px'
}

global.logToggle = function (id) {
  let logTime = document.getElementById('log-time-'+id)

  if (logTime.innerText == "1 day") {logTime.innerText = '1 month'}
  else if (logTime.innerText == "1 month") {
    if (id == "pb") {
      logTime.innerHTML = '&#8734;'
      toggleVisibility(true)
    }
    else {logTime.innerText = 'off'}
  } else {
    accessVisibility(document.getElementById('pb-visible').parentElement, true)
    logTime.innerText = '1 day'
  }
}

global.toggleSideSearchObject = function (object) {
  var title = object.children[1]
  var input = document.getElementById('side-search-input')

  if (title.innerText == 'People') {
    title.innerText    = 'Pages'
    input.dataset.type = 'pages'
    input.placeholder  = '        Find pages'
  } else {
    title.innerText    = 'People'
    input.dataset.type = 'people'
    input.placeholder  = '        Find people'
  }
  sideSearch("default")
}

global.toggleSideSearch = function () {
  var search = document.getElementById('side-search');
  document.getElementById('side-search-input').focus();

  search.classList.toggle('show');
  search.nextElementSibling.hidden = !search.nextElementSibling.hidden;
  if (search.nextElementSibling.hidden) {search_ids = []}
}

global.toggleVisibility = function (forcePublic) {
  let visible_txt = document.getElementById('pb-visible')
  let visible_btn = visible_txt.parentElement

  if (forcePublic) {
    accessVisibility(visible_btn, false)
    visible_txt.innerText = "public"
  } else {
    visible_txt.innerText = visible_txt.innerText == "public" ? "contacts" : "public"
  }
}

global.popMessage = function (message, className) {
  let box = document.getElementById('notification-box');
  box.innerHTML = message;
  box.className = className;
  box.style.animation = 'none';
  box.offsetHeight; /* trigger reflow */
  box.style.animation = null;
}

global.toggleUploadLabel = function (empty, elem_id) {
  if (!elem_id) elem_id = 'pb-upload'
  let article_upload = document.getElementById(elem_id)
  if (empty === undefined) empty = article_upload.value == ""

  article_upload.dataset.empty = empty
  article_upload.nextElementSibling.hidden = !empty
  article_upload.previousElementSibling.hidden = empty
}

function subdPage(page_name) {
  let elems = document.getElementById('write-page-list').getElementsByTagName('a')
  for (var i = 0; i < elems.length; i++) {if (elems[i].text == page_name) {return true}}
}

function accessVisibility(visible_btn, access) {
  visible_btn.disabled = !access
  access ? visible_btn.classList.remove('main-bg') : visible_btn.classList.add('main-bg')
}

function incrementElement(id) {
  let count = document.getElementById(id)
  count.innerText = Number(count.innerText) + 1
}

function decrementElement(id) {
  let count = document.getElementById(id)
  count.innerText = Number(count.innerText) - 1
}

// YOUTUBE IFRAMES

document.addEventListener("DOMContentLoaded",
  function() {
    var div, n;
    var videos = document.getElementsByClassName("youtube-player");
    for (n = 0; n < videos.length; n++) {
      div = document.createElement("div");
      div.setAttribute("data-id", videos[n].dataset.id);
      div.innerHTML = thumb(videos[n].dataset.id);
      div.onclick = iframe;
      videos[n].appendChild(div);
    }
  });

function thumb(id) {
  var thumb = '<img src="https://i.ytimg.com/vi/ID/hqdefault.jpg">';
  var play = '<div class="play"></div>';
  return thumb.replace("ID", id) + play;
}

function iframe() {
  var iframe = document.createElement("iframe");
  var embed = "https://www.youtube-nocookie.com/embed/ID?autoplay=1";
  iframe.setAttribute("src", embed.replace("ID", this.dataset.id));
  iframe.setAttribute("frameborder", "0");
  iframe.setAttribute("allowfullscreen", "1");
  this.parentNode.replaceChild(iframe, this);
}
