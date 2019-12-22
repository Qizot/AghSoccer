import express from "express";
import mongoose from "mongoose";
import path from "path";
import { UserModel } from "./models/user";
const app = express();
const port = 8080; // default port to listen

// Configure Express to use EJS
app.set( "views", path.join( __dirname, "views" ) );
app.set( "view engine", "ejs" );

// define a route handler for the default home page
app.get( "/", ( req, res ) => {
    // render the index template
    res.render( "index" );
} );

// start the express server
app.listen( port, () => {
    // tslint:disable-next-line:no-console
    console.log( `server started at http://localhost:${ port }` );
} );

const uri = "mongodb://localhost/agh_soccer";
mongoose.connect(uri, { 
    useNewUrlParser: true,
    useUnifiedTopology: true 
}, (err) => {
  if (err) {
    console.log(err.message);
    console.log(err);
  } else {
    console.log("Connected to MongoDb");
  }
});

UserModel.createUser("dupa", "dupa", "dupa")
.then((user) => console.log("created user: ", user))
.catch(err => console.log(err));
