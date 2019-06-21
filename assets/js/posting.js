import $ from "jquery" //TODO: need to find how to not repeat this line
// import * as shared from './shared'

class Posting {

  constructor () {
    // this.onRenderMoreMessages = this.onRenderMoreMessages.bind(this)
    // this.onRenderNewMessage = this.onRenderNewMessage.bind(this)
  }

  initialize (main) {
    this.main = main;
    // this.notifySound = new Audio("/sounds/notify_chat_message.wav")
  }

  // -------------------------- START ON CALLBACKS ----------------------------
  showGroups ({html: html, offset: offset}) {
    document.getElementById('side-search').dataset.offset = offset;
    replace("page-groups", html);
  }

  replace ({elem: elem, html: html}) {
    replace(elem, html);
  }

  onCreateChat ({html: html, messages_html: messages_html, id: id}) {
    var elemDiv = document.createElement('div');
    elemDiv.className = 'chat card';
    elemDiv.innerHTML = html;
    document.getElementById('chat-boxes').appendChild(elemDiv);
    openedChatPids.push(id);

    document.getElementById('events-box').classList.add("chat-opened");

    var message_area = elemDiv.children[2].firstElementChild
    message_area.innerHTML = messages_html;
    message_area.scrollTop = message_area.scrollTopMax;
  }

  onDelete ({elem_id: elem_id}){
    document.getElementById(elem_id).remove();
  }

  onDisableScroll ({elem_id: elem_id, direction: direction}){
    let elem = document.getElementById(elem_id)
    if (direction == "fwd") elem.dataset.scrollForward = "false"
    else elem.dataset.scrollBackward = "false"
    loadingResults = false;
  }

  onDisplayEdit ({elem_id: elem_id, html: html}){
    let elem = document.getElementById(elem_id)
    elem.hidden = true
    elem.insertAdjacentHTML('beforebegin', html)
  }

  onEdit ({elem_id: elem_id, html: html}){
    let elem = document.getElementById(elem_id);
    elem.innerHTML = html;
    elem.hidden = false;
  }

  // onLoadMoreArticles ({elem_id: elem_id, html: html, insert: insert, offset: offset}){
  //   let elem = document.getElementById(elem_id);
  //   elem.insertAdjacentHTML(insert, html);
  //   elem.dataset.offset = offset;
  //   loadingResults = false;
  // }

  onLoadMore (data){
    let elem = document.getElementById(data.elem_id);
    elem.insertAdjacentHTML(data.insert, data.html);
    elem.dataset.scrollBackward = data.scroll_bwd;
    elem.dataset.scrollForward  = data.scroll_fwd;
    elem.dataset.offset = data.offset;
    if (data.scroll_to) document.getElementById(data.scroll_to).scrollIntoView()
    loadingResults = false;
  }

  onNotify ({html: html, pid: pid}){
    notify(html, pid)
  }

  onPopMessage ({message: message, status: status}){
    popMessage(message, status)
  }

  onRenderMessage ({html: html, id: id}) {
    var elem = document.getElementById('chat_collapse'+id);
    var writeBox = document.getElementById('write-box');

    if (elem != undefined) {
      var elemDiv = document.createElement('div');
      elemDiv.className = 'comment';
      elemDiv.innerHTML = html;
      var message_area = elem.firstElementChild
      message_area.appendChild(elemDiv);
      message_area.scrollTop = message_area.scrollHeight;
    } else if (writeBox.hidden == false && writeBox.dataset.id == id) {
      var message_area = document.getElementById('write-messages');
      message_area.insertAdjacentHTML('beforeend', html);
      message_area.scrollTop = message_area.scrollHeight;
    } else {
      if (missedChatPids.indexOf(id) == -1) {
        chat_notif_nr += 1;

        // var chat_icon = document.getElementById('chat-icon');
        // chat_icon.className = "fa fa-comments";
        // chat_icon.nextElementSibling.innerText = chat_notif_nr;
        var chat_icons = document.getElementsByClassName('chat-icon')
        for (var i = 0; i < chat_icons.length; i++) {
          chat_icons[i].classList.replace("fa-comment-o", "fa-comment")
          chat_icons[i].nextElementSibling.innerText = chat_notif_nr;
        }

        popMessage(html, "info");
        missedChatPids.push(id);
      }
    }
  }

  onRenderWriteBoxMessage ({html: html, id: id, scroll_bwd: scroll_bwd, status: status, title: title}) {
    debugger
    var writeMessages = document.getElementById('write-messages');
    writeMessages.dataset.offset = 0
    writeMessages.dataset.persona = id
    writeMessages.dataset.scrollBackward = scroll_bwd
    writeMessages.dataset.status = status

    writeMessages.innerHTML = html;
    writeMessages.scrollTop = writeMessages.scrollHeight;
    document.getElementById('write-title').innerText = title;

    // TODO: attribute PID
  }

  onRenderArticle ({article_html: article_html, article_event: article_event, page_name: page_name, pid: pid, id: id}) {
    if (window.pid == id) {
      popMessage("Article posted!", "success")
      if (window.page_name == page_name || location.href.includes("/persona/")) {document.getElementById('content').insertAdjacentHTML('afterbegin', article_html);}
    } else notify(article_event, pid, page_name)

    // 1. if is the author and on the page
    // 2. else if events_tab closed || not main page  => increment notifications
    // 3. else if main page || event for page => prepend to events column
  }

  onRenderComment ({article_html_id: article_html_id, comment_html: comment_html, event_html: event_html, page_name: page_name, pid: pid}) {
    if (window.opened_article == article_html_id && window.pid == pid) {
      let comments = document.getElementById('comments')
      comments.hidden = false;
      comments.insertAdjacentHTML('beforeend', comment_html);
      comments.scrollTop = comments.scrollHeight;
    } else notify(event_html, pid, page_name)

    // 1. if opened article => append
    // 2. else if events_tab closed || (not main page && not event page)  => increment notifications
    // 3. else if main page || event for page => prepend to events column
  }

  onRenderComments ({article_id: article_id, html: html, scroll_bwd: scroll_bwd}) {
    let comments_textarea = document.getElementById('comments_textarea');
    let comments = document.getElementById('comments');
    let comments_panel = document.getElementById('comments_panel')

    comments_panel.hidden = false;
    comments_panel.firstElementChild.firstElementChild.href = "#article_"+article_id;
    comments_textarea.value = "";
    comments_textarea.hidden = false;

    // document.getElementById('ad').hidden = true;
    document.getElementById('events_panel').hidden = true;

    window.events_panel = false
    if (html == "") {
      comments.style.height = vh * 0.65 + "px";
      comments.hidden = true;
      comments_textarea.style.height = 0;
      commentsTextareaScrollHeight = comments_textarea.scrollHeight;
    } else {
      comments.dataset.scrollForward  = "false"
      comments.dataset.scrollBackward = scroll_bwd
      comments.dataset.articleId = article_id
      comments.innerHTML = html;
      comments.hidden = false;
      comments.scrollTop = comments.scrollHeight;
      commentsTextareaScrollHeight = comments_textarea.scrollHeight;
    }
  }

  onShowEvents ({events_html: events_html, personas_html: personas_html, title: title}) {
    // 1. If no events just show "no events" text
    // 2. add personas to div and events to hidden div. Then toggle through simple js.
    // document.getElementById('events-list').innerHTML = personas_html;
    document.getElementById('events-list').innerHTML = events_html;
    document.getElementById('events-title').innerHTML = title;
  }

  onShowOptions ({elem_id: elem_id}) {
    let options = document.getElementById(elem_id).nextElementSibling;
    options.children[1].hidden = false; options.children[2].hidden = false;
  }

  onShowPageMembers ({html: html}) {
    document.getElementById('page-box-members').innerHTML = html;
  }

  onShowBoxContacts ({html: html, name: name, id: id}) {
    document.getElementById('events-list').innerHTML = html;
    // selectWObject('message', name, id);
    // document.getElementById('write-box').hidden = false;
  }
  onShowBoxPages ({html: html}) {
    document.getElementById('events-list').innerHTML = html;
  }

  onRenderSideSearchResults ({html: html, ids: ids}) {
    search_ids = ids;
    replace('page-groups', html);
  }

  //
  // onRenderNewMessage (message) {
  //   let messageList = document.getElementById("chat_messages_")
  //   let input = $("#chat-input")
  //
  //   messageList.insertAdjacentHTML('beforeend', message.body );
  //   shared.formatInsertedAt(message.inserted_at, `${message.id}_chat`)
  //   messageList.scrollTop = messageList.scrollHeight
  //
  //   if (play_sound()) {
  //     this.notifySound.currentTime = 0
  //     this.notifySound.play()
  //   }
  //
  //   input.val("");
  // }

  // -------------------------- END ON CALLBACKS ------------------------------

  // renderOldMessage (message) {
  //   let messageList = document.getElementById("chat_messages_")
  //
  //   messageList.insertAdjacentHTML('afterbegin', message.body );
  //   shared.formatInsertedAt(message.inserted_at, `${message.id}_chat`)
  //   this.main.chat_offset_id = message.id
  // }
}
export default Posting

function notify(html, pid, page_name) {
  if (should_increment(pid, page_name)) { incrementNotifications() }
  else if (window.pid == pid) { addToEvents(html) }
}

function addToEvents(html) {
  document.getElementById("events").insertAdjacentHTML('afterbegin', html);
}

function incrementNotifications() {
  post_notif_nr += 1;
  var posts_icon = document.getElementById('posts-icon');
  posts_icon.className = 'fa fa-file-text';
  posts_icon.nextElementSibling.innerText = post_notif_nr;
}

function should_increment(pid, page_name) {
  return notify_on_not_current_persona(pid) || (window.pid == pid && (window.events_panel == false || not_on_main_page(page_name)))
  // return notify_on_not_current_persona(pid) || (window.pid == pid && window.page_name != page_name) // trying out to show posts if on page
}

function notify_on_not_current_persona(pid) {
   return window.connected_personas && window.pid != pid
}

function not_on_main_page(page_name) {
  return window.page_name != "" && window.page_name != page_name
}

function replace(elem, html) {
  document.getElementById(elem).innerHTML = html;
}

// function play_sound() {
//   return ($(window).data("visibility") == "blur") ||
//   ($('#minim_chat_window').hasClass('panel-collapsed'))
// }
