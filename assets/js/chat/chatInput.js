export default ChatInput = {
  mounted() {
    const target = this.el.dataset.target

    this.el.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault()
        if (this.el.value.trim() === "") return
        this.pushEventTo(target, "send_message", { body: this.el.value })
        this.el.value = ""
        this.el.focus()
      }
    })

    this.handleEvent("clear_input", () => {
      this.el.value = ""
      this.el.focus()
    })
  }
}
