import setup, {Server, Socket} from "socket.io";
import { Server as HTTPServer } from "http";
import { RoomManager, ChatActions } from "../chat/room_manager";




class SocketManager {
    private static instance: SocketManager;

    private io: Server;
    private roomManager: RoomManager;

    static get IO () {
        if (!SocketManager.instance) {
            throw Error("socket manager has not been initialized");
        } 
        return SocketManager.instance.io;
    }

    static initialize(server: HTTPServer, roomManager: RoomManager) {
        if (SocketManager.instance)
            throw Error("socket manager has been already initialized");

        SocketManager.instance = new SocketManager(setup(server), roomManager);
    }

    /* 
        Function managing socket, setting all necessary callbacks
        to send and receive messages from socket
    */
    static manageSocket(socket: Socket, nickname: string) {
        if (!SocketManager.instance)
            throw new Error("socket manager has not been initialized");
        
        const namespace = socket.nsp;
        const roomName = socket.nsp.name.split("/").filter(el => el !== "")[0];
        socket.on(ChatActions.Send, async (msg: string) => {
            const message = {
                nickname,
                message: msg,
                timestamp: new Date()
            };
            try {
                await SocketManager.instance.roomManager.saveMessage(roomName, message);
                namespace.emit(ChatActions.Message, message);
            } catch (err) {
                console.log(`ChatRoom ${roomName}: got an error while sending message: ${err}`);
                socket.emit(ChatActions.Error, `failed to send message: ${err}`)
            }
        });

        socket.on(ChatActions.GetMessages, async () => {
            try {
                const messages = await SocketManager.instance.roomManager.fetchChatRoomMessages(roomName);
                socket.emit(ChatActions.AllMessages, messages);
            } catch (err) {
                console.log(`ChatRoom ${roomName}: got an error while fetching messages: ${err}`);
                socket.emit(ChatActions.Error, `failed to fetch messages: ${err}`)
            }
        });
    }

    private constructor (server: Server, manager: RoomManager) {
        this.io = server;
        this.roomManager = manager;
    }

}

export default SocketManager;