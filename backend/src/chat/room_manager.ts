import { ChatMessage, ChatRoom, ChatRoomType } from "../models/chat";

export enum ChatActions {
    Send = "send",
    GetMessages = "getMessages",
    Message = "message",
    AllMessages = "allMessages",
    Error = "errors"
}

export interface RoomManager {
    saveMessage: (room: string, message: ChatMessage) => Promise<void>;
    fetchChatRoomMessages: (room: string) => Promise<ChatMessage[]>;
}


const mongoSaveMessage = async (roomId: string, message: ChatMessage) => {
    const model = await ChatRoom.findRoom({matchId: roomId}) as ChatRoomType;
    if (!model)
        throw new Error("room has not been found");
    const room = new ChatRoom(model);
    await room.saveMessage(message);
}

const mongoFetchChatRoomMessages = async (roomId: string) => {
    const model = await ChatRoom.findRoom({matchId: roomId}) as ChatRoomType;
    console.log(model);
    console.log("RoomId: ", roomId);
    if (!model)
        throw new Error("room has not been found");
    return model.messages.map(msg => ({nickname: msg.nickname, message: msg.message, timestamp: msg.createdAt}));
}

export const defaultRoomManager: RoomManager = {
    saveMessage: mongoSaveMessage,
    fetchChatRoomMessages: mongoFetchChatRoomMessages
};