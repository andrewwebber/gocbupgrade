package main

import (
	"fmt"
	"log"
	"time"

	"github.com/couchbase/gocb"
)

type User struct {
	Id        string   `json:"uid"`
	Email     string   `json:"email"`
	Interests []string `json:"interests"`
}

func main() {
	log.SetFlags(log.Llongfile)
	var cluster *gocb.Cluster
	var err error
	for {
		cluster, err = gocb.Connect("couchbase://localhost")
		if err == nil {
			break
		}

		log.Println(err)
		time.Sleep(2 * time.Second)
	}

	bucket, err := cluster.OpenBucket("default", "")
	if err != nil {
		if err.Error() == "authentication error" {
			log.Println(" Assume using CouchbaseV5")
			err = cluster.Authenticate(gocb.PasswordAuthenticator{
				Username: "Administrator",
				Password: "password",
			})

			if err != nil {
				log.Println("// Could be a real auth issue like invalid username or password")
				log.Fatal(err)
			}

			bucket, err = cluster.OpenBucket("default", "")
			if err != nil {
				log.Fatal(err)
			}
		}

		if err != nil {
			log.Fatal(err)
		}
	}

	_, err = bucket.Upsert("u:kingarthur",
		User{
			Id:        "kingarthur",
			Email:     "kingarthur@couchbase.com",
			Interests: []string{"Holy Grail", "African Swallows"},
		}, 0)
	if err != nil {
		log.Fatal(err)
	}

	// Get the value back
	var inUser User
	bucket.Get("u:kingarthur", &inUser)
	fmt.Printf("User: %v\n", inUser)
}
