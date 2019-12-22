import express from "express";
import mongoose from "mongoose";
import logger from "morgan";
import indexRouter from './routes/index';

const app = express();
const port = 8080; // default port to listen
const mongoUri = "mongodb://localhost/agh_soccer";

app.use(logger('dev'));
app.use(express.json());


app.listen( port, () => {
    // tslint:disable-next-line:no-console
    console.log( `server started at http://localhost:${ port }` );
});

app.use("/api", indexRouter);


mongoose.connect(mongoUri, { 
    useNewUrlParser: true,
    useUnifiedTopology: true 
}, (err) => {
  if (err) {
    console.log(err);
  } else {
    console.log("Connected to MongoDb");
  }
});
