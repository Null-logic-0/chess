export default CopyToClipboard = {
  mounted() {
    this.el.addEventListener("click", () => {
      const url = this.el.dataset.url
      navigator.clipboard.writeText(url).then(() => {
        this.pushEvent("copied_link", {})
      }).catch(() => {
        const input = document.createElement("input")
        input.value = url
        document.body.appendChild(input)
        input.select()
        document.execCommand("copy")
        document.body.removeChild(input)
        this.pushEvent("copied_link", {})
      })
    })
  }
}
