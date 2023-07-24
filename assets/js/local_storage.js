export function save_messages(chat_id, messages) {
    const storage = window["localStorage"]
    storage.setItem("messages:" + chat_id, JSON.stringify(messages))
  }
  
  export function get_localstorage_msgs(chat_id) {
    const storage = window["localStorage"]
    const value = storage.getItem("messages:" + chat_id)
    return JSON.parse(value)
  }
  
  export function clear_msg_input(chat_id) {
    const storage = window["localStorage"]
    storage.removeItem("messages:" + chat_id)
  }