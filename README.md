<div align="center">
  <h1>♞ ChessHub </h1>
  <p><strong>A real-time, highly concurrent Chess application built with Elixir and the Phoenix Framework.</strong></p>
  
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  [![Elixir](https://img.shields.io/badge/Language-Elixir-4B275F?logo=elixir)](https://elixir-lang.org/)
  [![Phoenix](https://img.shields.io/badge/Framework-Phoenix-FD4F00?logo=phoenix)](https://www.phoenixframework.org/)
</div>

--- 

## 📖 Overview

Welcome to **Chess**, a robust and scalable web-based chess application. By leveraging Elixir's functional concurrency model and the Phoenix framework's real-time capabilities, this platform aims to deliver a seamless, low-latency multiplayer chess experience. It utilizes Elixir's actor model (OTP) for flawless state management across simultaneous matches.

--- 

## 🕹️ Game Demo

https://github.com/user-attachments/assets/dca472c1-ee3a-4772-bb1f-7d6fc130cde5


https://github.com/user-attachments/assets/dda0d856-5208-4253-9ce5-b4281954ad30



https://github.com/user-attachments/assets/55b26f43-4d15-4ad8-80e8-40b710796438



---

## ✨ Features

- **Real-Time Gameplay:** Lightning-fast move synchronization with zero noticeable latency, powered by Phoenix WebSockets / LiveView.
- **High Concurrency:** Fault-tolerant architecture capable of running and isolating thousands of simultaneous chess matches.

- **Interactive UI:** Clean, responsive front-end tailored for an intuitive user experience.

---

## 🛠️ Technology Stack

- **Backend:** [Elixir](https://elixir-lang.org/), [Phoenix Framework](https://www.phoenixframework.org/)
- **Frontend:** LiveView, JavaScript
- **Build Tool / Package Manager:** Mix

--- 

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Ensure you have the following installed on your system:
- **Elixir** (v1.15 or higher recommended)
- **Erlang/OTP** (v24 or higher recommended)
- **Node.js** (for compiling frontend assets)
- **PostgreSQL** (if database persistence/Ecto is configured)

### Installation

1. **Clone the repository:**
```bash
   git clone https://github.com/Null-logic-0/chess.git
   cd chess
```

2. **Install and set up dependencies:**
```bash
mix setup 
```

3. **Run Tests**
```bash 
mix test
```

4. **Read Docs**
```bash 
mix docs
```
This will generate HTML docs inside:

```bash 
doc/index.html
```
Open the docs

```bash 
open doc/index.html
```

5. **Start Server**
```bash 
# Standard start
mix phx.server

# Start with an interactive shell
iex -S mix phx.server
```

Open your favorite web browser 
and navigate to **http://localhost:4000**.


---

## 🌍 Deployment

Ready to take this application live? The Phoenix framework makes deployment straightforward. Please refer to the **[official deployment guides](https://hexdocs.pm/phoenix/deployment.html)** to best prepare your app for a production environment.

---

## 🤝 Contributing

Contributions, issues, and feature requests are always welcome!
Feel free to check the **issues page**. If you'd like to contribute code, please fork the repository, create a feature branch, and submit a pull request.


---

## 📄 License

This project is open-source and licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.


