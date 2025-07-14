<a name="readme-top"></a>
<div align="center">

  <h3><b>AI Financial Advisor Application</b></h3>

</div>

# 📗 Table of Contents

- [📗 Table of Contents](#-table-of-contents)
- [Issue Tracker ](#-ai-financial-advisor-)
  - [🛠 Built With ](#-built-with-)
    - [Tech Stack ](#tech-stack-)
    - [Key Features ](#key-features-)
  - [💻 Getting Started ](#-getting-started-)
    - [Prerequisites](#prerequisites)
    - [Setup](#setup)
    - [Install](#install)
    - [Run tests](#run-tests)
    - [Usage](#usage)
  - [👥 Author ](#-author-)
  - [🔭 Future Features ](#-future-features-)
  - [🤝 Contributing ](#-contributing-)
  - [⭐️ Show your support ](#️-show-your-support-)
  - [🙏 Acknowledgments ](#-acknowledgments-)
  - [📝 License ](#-license-)

# AI Financial Advisor <a name="ai-financial-advisor"></a>

**AI Financial Advisor** is a Rails-based AI assistant for financial advisors that integrates with Gmail, Google Calendar, and HubSpot. It uses RAG (Retrieval-Augmented Generation) with Ollama to provide intelligent responses, context-aware actions, and proactive workflows. 


[Live demo]()



## 🛠 Built With <a name="built-with"></a>

### Tech Stack <a name="tech-stack"></a>

- **[Ruby](https://www.ruby-lang.org/en/)**
- **[Ruby on Rails](https://rubyonrails.org/)**
- **[PostgreSQL](https://www.postgresql.org/)**

### Key Features <a name="key-features"></a>

- Stream AI chat with memory and tool usage
- Gmail integration to send/receive/summarize emails
- Google Calendar integration for smart scheduling
- HubSpot integration to sync and create contacts and notes
- RAG (Retrieval-Augmented Generation) powered by embeddings
- Ongoing instructions ("rules") to automate actions (e.g., auto-create HubSpot contacts)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 💻 Getting Started <a name="getting-started"></a>

To get a local copy up and running, follow these steps.

### Prerequisites

To run this project you need:

- Install [Ruby](https://www.ruby-lang.org/en/)
- Install [Ruby on Rails](https://rubyonrails.org/)
- Install [PostgreSQL](https://www.postgresql.org/)
- Install [Ollama](https://ollama.com/)  locally for LLM inference
### Setup

Clone this repository to your desired folder:

`git clone https://github.com/fatmahussein/ai_financial_advisor.git`
`cd ai-financial-advisor`

### Install

Install the required gems
`bundle install`

Create the database by running the command
`rails db:create`

Migrate the tables to the database
`rails db:migrate`

Make sure you have .env or credentials.yml.enc configured with your OAuth keys. 

`
GOOGLE_CLIENT_ID= 
GOOGLE_CLIENT_SECRET=
HUBSPOT_CLIENT_ID=
HUBSPOT_CLIENT_SECRET=
HUBSPOT_REDIRECT_URI=
HUBSPOT_SCOPES= example scopes
GOOGLE_REDIRECT_URI=http://localhost:3000/users/auth/google_oauth2/callback
`


### Run tests

Run the tests using
`rspec`

### Usage

Then run the rails server

`rails s`

And now you should be able to see the project running on `localhost:3000`

Visit `http://localhost:3000/exports` to download issues as PDF or Excel.


<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 👥 Author <a name="authors"></a>

👤 **Fatuma Hussein**

- GitHub: [@fatmahussein](https://github.com/fatmahussein)
- LinkedIn: [Fatuma Hussein](https://www.linkedin.com/in/fatmahusseinhassan/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 🔭 Future Features <a name="future-features"></a>

- Full scheduling workflow with auto-email + calendar link
- Web UI for instruction rule builder

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 🤝 Contributing <a name="contributing"></a>

Contributions, issues, and feature requests are welcome!

Feel free to check the [issues page](../../issues/).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## ⭐️ Show your support <a name="support"></a>

Leave a ⭐️ if you like this project!

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 🙏 Acknowledgments <a name="acknowledgements"></a>

- Inspired by Jump technical interview

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 📝 License <a name="license"></a>

This project is [MIT](./LICENSE) licensed.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
