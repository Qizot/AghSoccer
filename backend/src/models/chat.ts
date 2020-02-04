import mongoose, { Schema } from "mongoose";
import { RepositoryBase } from "./model_base";

export interface ChatMessage {
    nickname: string;
    createdAt?: Date,
    message: string;
}

export interface ChatRoomType extends mongoose.Document {
    matchId: string;
    messages: ChatMessage[];
}

const messageSchema = new Schema({
    nickname: {
        type: String,
        required: true
    },
    message: {
        type: String,
        maxlength: 200
    },
},
{
    timestamps: true
});


const schema = new Schema({
    matchId: {
        type: Schema.Types.ObjectId,
        required: true,
    },
    messages: {
        type: [messageSchema],
        default: []
    }
}, { timestamps: true });

export const ChatRoomSchema = mongoose.model<ChatRoomType>("chatRoom", schema, "chatRooms");

export class ChatRoom {

    get id(): string {
        return this._chatRoomModel.id;
    }

    get messages(): ChatMessage[] {
        return this._chatRoomModel.messages;
    }


    public static createRoom(matchId: string): Promise<mongoose.Document> {
        return new Promise((resolve, reject) => {
            const repo = new ChatRoomRepository();

            const room: Partial<ChatRoomType> = {
                matchId
            };

            repo.create(room)
                .then((room) => resolve(room))
                .catch((err) => reject(err));
        });
    }

    public saveMessage(message: ChatMessage): Promise<mongoose.Document> {
        this._chatRoomModel.messages.push(message);
        return this._chatRoomModel.save();
    }

    public static findRoom({id, matchId}: {id?: string; matchId?: string;}): Promise<mongoose.Document> {
        const params = {};

        if (id) { params["_id"] = id; }
        if (matchId) { params["matchId"] = matchId; }

        return new Promise((resolve, reject) => {
            const repo = new ChatRoomRepository();

            repo.findOne({...params}).exec()
                .then((doc) => resolve(doc))
                .catch((err) => reject(err));
        });
    }

    public static findOne(cond: Object, fields: Object): Promise<mongoose.Document> {
        const repo = new ChatRoomRepository();
        return new Promise((resolve, reject) => {
            repo.find(cond, fields, (err, item) => {
                if (err) {
                    reject(err);
                    return;
                }
                resolve(item.find((el) => !!el));
            });
        });
    }

    public static deleteChatRoom(matchId: string): Promise<void> {
    
        return new Promise((resolve, reject) => {
            ChatRoomSchema.deleteOne({matchId: matchId}, (err) => {
                if (err) {
                    reject(err);
                    return;
                }
                resolve();
            })
        });
        
    }

    private _chatRoomModel: ChatRoomType;

    constructor(chatRoomModel: ChatRoomType) {
        this._chatRoomModel = chatRoomModel;
    }

}

export class ChatRoomRepository extends RepositoryBase<ChatRoomType> {

    constructor() {
        super(ChatRoomSchema);
    }
}
