import Posting from './posting'
import Triggers from './triggers'
import {Presence} from 'phoenix'

let posting    = new Posting

class Main {
  constructor (socket) {
    this.socket = socket;
    window.presences = [];
  }

  initialize (topic) {
    // Set up the websocket connection
    this.socket.connect()
    // console.log(this.socket);
    // this.page_room = this.socket.channel("room:" + topic)
    this.persona_room = this.socket.channel("room:" + user_id)

    this.persona_room.on('comments:show',          posting.onRenderComments)
    this.persona_room.on('article:append',         posting.onRenderArticle)
    this.persona_room.on('chat:create',            posting.onCreateChat)
    this.persona_room.on('chat:wchat_open',        posting.onRenderWriteBoxMessage)
    this.persona_room.on('chat:message_create',    posting.onRenderMessage)
    this.persona_room.on('comment:append',         posting.onRenderComment)
    this.persona_room.on('delete',                 posting.onDelete)
    this.persona_room.on('display_edit',           posting.onDisplayEdit)
    this.persona_room.on('edit',                   posting.onEdit)
    // this.persona_room.on('load_more_articles',     posting.onLoadMoreArticles)
    // this.persona_room.on('load_more_comments',     posting.onLoadMoreComments)
    this.persona_room.on('load_more',              posting.onLoadMore)
    this.persona_room.on('disable_scroll',         posting.onDisableScroll)
    this.persona_room.on('notify',                 posting.onNotify)
    this.persona_room.on('popMessage',             posting.onPopMessage)
    this.persona_room.on('replace',                posting.replace)
    this.persona_room.on('show_box_contacts',      posting.onShowBoxContacts)
    this.persona_room.on('show_box_pages',         posting.onShowBoxPages)
    this.persona_room.on('show_groups',            posting.showGroups)
    this.persona_room.on('show_events',            posting.onShowEvents)
    this.persona_room.on('show_options',           posting.onShowOptions)
    this.persona_room.on('show_page_members',      posting.onShowPageMembers)
    this.persona_room.on('side_search',            posting.onRenderSideSearchResults)


    // ---PRESENCE HANDLING---

    // Sync presence state
    this.persona_room.on('presence_state', state => {
      var state_keys = Object.keys(state)
      this.renderPresences(state_keys)
      presences = state_keys;
    })
    // Handle messages that are sent to topics that don't have a client side representation
    this.socket.onMessage(({topic, event, payload}) => {
      if (event == "presence_diff" && /^user_presence:/.test(topic)) {
        if (Object.keys(payload.joins).length > 0) {
          var state_keys = Object.keys(payload.joins)
          this.renderPresences(state_keys)
          presences = presences.concat(state_keys)
        }
        if (Object.keys(payload.leaves).length > 0) {
          var state_keys = Object.keys(payload.leaves)
          this.renderPresences(state_keys);
          for (var i = 0; i < state_keys.length; i++) {
            var index = presences.indexOf(state_keys[i]);
            if (index > -1) {presences = presences.splice(index, 1)}
          }
        }
      }
    })

    this.persona_room.join()
      .receive("ok", resp => { console.log("Connection ok."); })
      .receive("error", resp => { console.log("Connection failed. Contact administrator") })
//
//     // Variables
//     this.chat_offset_id = -1
//     this.chat_allowed_to_get_more = true
//
    let main = this
    new Triggers(main)
    posting.initialize(main)
  }

  renderPresences(state_keys) {
    var contacts_container   = document.getElementById('page-groups')
    var write_box_container  = document.getElementById('write-box')
    var chat_boxes_container = document.getElementById('chat-boxes')
    var elements = []
    for (var i = 0; i < state_keys.length; i++) {
      if (contacts_container) {
        elements = contacts_container.querySelectorAll("img[src$='/profiles/"+state_keys[i]+".jpg']")
        for (var x = 0; x < elements.length; x++) { elements[x].parentElement.parentElement.classList.toggle("offline") }
      }

      if (chat_boxes_container) {
        elements = chat_boxes_container.querySelectorAll("img[src$='/profiles/"+state_keys[i]+".jpg']")
        for (var z = 0; z < elements.length; z++) { elements[z].parentElement.classList.toggle("offline") }
      }

      elements = write_box_container.querySelectorAll("img[src$='/profiles/"+state_keys[i]+".jpg']")
      for (var y = 0; y < elements.length; y++) { elements[y].parentElement.classList.toggle("offline") }
    }
  }
}

export default Main
