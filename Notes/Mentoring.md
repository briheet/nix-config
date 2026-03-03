# Golang

Golang is a language built for systems and not just for backend. Hence things like TUI, backends, cli tools, etc are built in golang.
Some resources you should learn by heart

1. https://go.dev/doc/ - This is official go docs. You should get a good idea about various things from here. Majourly go core stuff.
2. https://devdocs.io/go/ - you should not learn this by heart. just give it a glance on weekends.
3. [Backend github repo](https://github.com/christianselig/apollo-backend) - This is one of the best basics golang backend ever written. It was ios reddit official backend for a while. Start reading code from main.go and google each and everyline. Thats how you will know good programming. 
4. [Conference link](https://www.youtube.com/results?search_query=golang+confrence) - Please in your free time go through the golang conference videos. Conference is a place where people with multiple years of valid experience come and hence mostly good knowledge. I say interviews are a lot conference based knowledge and concurrency based.
5. Most writing code is library based and you will have to learn standard library hence look into core packages used daily. Some of them are net/http, strings, bufio, sync package. This will put you in a really good position. Most golang engineers in coorperate use it just for writing code hence you will have an upper advantage if you know it in detail.

## Ways of writing code

Whenever you start a project. You define it in root repo by cmd. The entrypoint in any application is a cli. This cli is useful starting your backend, applying migrations, spinning up workers, and many other things.

The cli best to use is cobra := [Cobra](https://cobra.dev/)
Here is a way cobra is written := [Way](https://github.com/christianselig/apollo-backend/blob/main/internal/cmd/root.go)
Ask me if you have any doubts.

After your code enters the program, its should first load all the config. Config can in many places like yaml files, toml files, [Vault](https://www.hashicorp.com/en/products/vault)
Hence for that use Viper := [Viper](https://github.com/spf13/viper) With viper you define structs and you tags. Also you can use the golang validator package to validate if its nil or not while loading. Saves you a ton of headache. 