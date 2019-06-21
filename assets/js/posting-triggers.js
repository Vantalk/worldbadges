import $ from "jquery" //TODO: need to find how to not repeat this line

class PostingTrigger {

  initialize (main) {
    // TODO: maybe move to other trigger js
    $(document).on('click', '#notifications_btn', function(event) {
      if (window.events_panel == true) { return }
      toggle_events_panel()
      // TODO: get latest notifications
    });

    // maybe move to own trigger js
    $(document).on('click', "[data-chat]", function(event) {
      var persona_id = this.dataset.chat
      var pid = this.dataset.pid

      // TODO: pop chat boxes in cascade style based on openedChatPids increments
      // TODO: store chat id to cookie/store
      // if (main.chat.indexOf(persona_id) > -1) {
      if (openedChatPids.indexOf(persona_id) == -1) {
      //   main.chat
        main.persona_room.push('chat:create', {persona_id: persona_id, pid: pid, presences: presences});
      }
    });

    // $(document).on('click', "[data-wchat]", function(event) {
    //   var persona_id = this.dataset.wchat
    //   var missed = this.children[1]
    //   var status = this.classList.contains("offline") ? "offline" : " "
    //   document.getElementById('write-box').dataset.id = persona_id;
    //   if (missed != undefined) {missed.remove(); missed=true}
    //   else (missed = false)
    //   main.persona_room.push('chat:wchat_open', {persona_id: persona_id, missed: missed, status: status});
    // });
    // -------

    $(document).on('click', '#append_comment', function(event) {
      let textarea = document.getElementById('comments_textarea')
      main.persona_room.push('posting:comment_create', {obj_id: window.opened_article, content: textarea.value});
      textarea.value = ""
      textarea.focus()
    });

    $(document).on('mousedown', '.article_content', function(event) {
      window.fire_click = true;
      setTimeout(function() {
        window.fire_click = false;
      }, 1000);
    });

    $(document).on('mouseup', '.article_content', function(event) {
      let article_element = this.parentElement.parentElement;
      if (window.fire_click == true) {
        if (window.opened_article == article_element.id) {
          toggle_events_panel()
          window.opened_article = undefined;
        }
        else {
          if (window.opened_article != undefined && window.opened_article != "") {
            document.getElementById(window.opened_article).classList.remove('opened_article');
          }

          article_element.classList.add('opened_article');
          window.opened_article = article_element.id

          // add Opened article to writeBox
          // document.getElementById('write-comment').className = ""
          // if (wCategory == null) {
          //   var writeBox = document.getElementById('write-box');
          //   writeBox.dataset.id = window.opened_article;
          //   writeBox.dataset.type = "comment";
          //   document.getElementById('write-title').innerText = "Write comment for opened article"
          //
          //   let urlArray = document.location.href.split('/')
          //   let page_type = urlArray[3]
          //   let page_name = urlArray[4]
          //
          //   if (page_type == 'persona') {
          //     document.getElementById('log-time-write').parentElement.hidden = false;
          //     document.getElementById('write-visible').parentElement.parentElement.hidden = true;
          //   } else {
          //     document.getElementById('log-time-write').parentElement.hidden = true;
          //     document.getElementById('write-visible').parentElement.parentElement.hidden = true;
          //   }
          // }
          document.getElementById('comments').innerHTML = ""
          main.persona_room.push('posting:comments_show', {article_id: article_element.id});
        }
      }

      // if(event.keyCode == 13  && !event.shiftKey) {
      //   create_new_chat_message(main)
      //   event.preventDefault();
      // }
    });

    $(document).on('click', '[id^="copt_"]', function(event) {
      main.persona_room.push('posting:enable_comment_options', {options_id: this.id});
    });

    $(document).on('click', '[id^="aopt_"]', function(event) {
      main.persona_room.push('posting:enable_article_options', {options_id: this.id});
    });

    $(document).on('click', '[data-delegated]', function(event) {
      loadMore(document.getElementById(this.dataset.delegated), 'page_articles')
    });

    $(document).on('click', '[data-report]', function(event) {
      let report_modal = $('#report-modal')
      let report_post_options = report_modal[0].querySelector("[id='report-post-options']")
      let report_user_options = report_modal[0].querySelector("[id='report-user-options']")
      let dataset = this.dataset;

      let report_user = dataset.report == "user"
      report_post_options.hidden = report_user;
      report_user_options.hidden = !report_user;
      if (!report_user) { dataset = this.parentElement.dataset }

      report_modal.modal('toggle')
      report_modal = report_modal[0]
      report_modal.dataset.type = dataset.type
      report_modal.dataset.id   = dataset.id
    });

    $(document).on('click', '[data-delete]', function(event) {
      main.persona_room.push('posting:delete_'+this.parentElement.dataset.type, {id: this.parentElement.dataset.id});
    });

    $(document).on('click', '[data-edit]', function(event) {
      main.persona_room.push('posting:display_edit', {type: this.parentElement.dataset.type, id: this.parentElement.dataset.id});
    });

    $(document).on('click', "[data-recognize]", function(event) {
      // if (confirm("Use this power wisely.")) {
        var element = this.dataset.recognize
        main.persona_room.push('posting:recognize', {element: element});
      // }
    });


    // $(document).on('click', '#btn-chat', function(event) {
    //   create_new_chat_message(main)
    // });
    //
    // // handle scroll of the chat box - get new chat messages
    // $('#chat_messages_').scroll(function() {
    //   if(($(this).scrollTop() == 0) && (main.chat_allowed_to_get_more)) {
    //     main.chat_allowed_to_get_more = false;
    //     $(this).scrollTop(60);
    //     main.project_room.push('messages:get_more', {offset_id: main.chat_offset_id});
    //   }
    // });
  }
}
export default PostingTrigger

// function toggle_events_panel() {
//   var ad = document.getElementById('ad')
//   var comments_panel = document.getElementById('comments_panel')
//   var events_panel   = document.getElementById('events_panel')
//
//   ad.hidden = !ad.hidden
//   comments_panel.hidden = !comments_panel.hidden
//   events_panel.hidden = !events_panel.hidden
//   window.events_panel = !window.events_panel
//   $('#'+window.opened_article).toggleClass("opened_article")
//   window.opened_article = undefined;
//   // document.getElementById('write-comment').hidden = true;
// }




// create chat message
// function create_new_chat_message(main) {
//   let input = $("#chat-input")
//   let content = input.val();
//
//   if(!content) return;
//
//   main.project_room.push('message:new', {content: content});
// }
