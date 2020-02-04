import express from "express";
import mongoose from "mongoose";
import logger from "morgan";
import indexRouter from "./routes/index";
import SocketManager from "./chat/socket";

import { checkToken, TokenResult } from "./middleware/auth";
import { Socket } from "socket.io";
import { defaultRoomManager } from "./chat/room_manager";
import { MatchModel } from "./models/match";

const app = express();

const port = 8080; // default port to listen
const mongoUri = "mongodb://localhost/agh_soccer";

app.use(logger("dev"));
app.use(express.json());

const server = app.listen( port, () => {
    // tslint:disable-next-line:no-console
    console.log( `Server started at http://localhost:${ port }` );
});

app.use("/api", indexRouter);

mongoose.connect(mongoUri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
}, (err) => {
  if (err) {
    console.log("MongoDB: ", err);
  } else {
    console.log("Connected to MongoDb");
  }
});


// CHAT INITIALIZATION

// initialize socket.io socket
SocketManager.initialize(server, defaultRoomManager);

// setup chat connection manager
// allow only namespaces that match mongodb id format
const chatRoomConnectionManager = SocketManager.IO.of(/^\/[a-z0-9]+$/);


// setup auth middleware
chatRoomConnectionManager.use( async (socket: Socket, next: (err?: any) => void) => {
  if (socket.handshake.query && socket.handshake.query.token) {
    const token = socket.handshake.query.token;

    const partial = socket.nsp.name.split("/").filter(el => el !== "");
    
    if (partial.length < 1) {
      return next(new Error("no matchId has been specified"));
    }
    const matchId = partial[0];


    const {status, user} = await checkToken({token, omitFormatCheck: true});
    if (status !== TokenResult.Success) {
      return next(new Error(status));
    }

    const isMatchMember= await MatchModel.isUserMatchMember(matchId, user.nickname);
    if (!isMatchMember) {
      return next(new Error("user is not match's member"));
    }

    SocketManager.manageSocket(socket, user.nickname);
    next();
  } else {
    return next(new Error("no token has been speciefied as query params"));
  }
});
