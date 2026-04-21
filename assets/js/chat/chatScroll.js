export default ChatScroll = {
  mounted() {
    this.scrollToBottom()
  },
  updated() {
    this.scrollToBottom()
  },
  scrollToBottom() {
    this.el.scrollTop = this.el.scrollHeight
  }
}
