import bcrypt from "bcrypt";
import mongoose, { Schema } from "mongoose";
import { RepositoryBase } from "./model_base";

interface UserCredentials {
    password: string;
    tokenInfo?: {
        token: string;
        refreshToken: string;
    };
}

export interface PlainUser {
    _id: string;
    email: string;
    nickname: string;
    matchesPlayed?: string[];
    roles: string[];
}

export interface UserModelType extends mongoose.Document {
    email: string;
    nickname: string;
    credentials: UserCredentials;
    createdAt?: Date;
    matchesPlayed?: string[];
    roles: string[];
}

const validateEmail = function(email) {
    const re = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
    return re.test(email);
};

const schema = new Schema({
    email: {
        type: String,
        required: true,
        validate: [validateEmail, "email must match standard"],
        index: {
            unique: true,
        },
    },
    nickname: {
        type: String,
        required: true,
        minlength: 4,
        maxlength: 20,
        unique: true

    },
    credentials: {
        password: {
            type: String,
            required: String,
        },
        tokenInfo: {
            token: {
                type: String,
            },
            refreshToken: {
                type: String,
            },
        },
    },
    matchesPlayed: [Schema.Types.ObjectId],
    roles: {
        type: [
            {
                type: String,
                enum: ["user", "admin"],
            },
        ],
        default: ["user"],
    },
}, { timestamps: true });

export const UserSchema = mongoose.model<UserModelType>("user", schema, "users");

export class UserModel {

    get id(): string {
        return this._userModel.id;
    }

    get email(): string {
        return this._userModel.email;
    }

    get nickname(): string {
        return this._userModel.nickname;
    }

    get credentials(): UserCredentials {
        return this._userModel.credentials;
    }

    get matchesPlayed(): string[] {
        return this._userModel.matchesPlayed;
    }

    get plainUser(): PlainUser {
        const {_id, email, nickname, matchesPlayed, roles} = this._userModel;
        return {_id, email, nickname, matchesPlayed, roles};
    }

    get roles(): string[] {
        return this._userModel.roles;
    }

    public static createUser({email, nickname, password}: {
        email: string;
        nickname: string;
        password: string;
    }): Promise<mongoose.Document> {
        return new Promise((resolve, reject) => {
            const repo = new UserRepository();

            const passwordHash = bcrypt.hashSync(password, 10);

            const user: Partial<UserModelType> = {
                email,
                nickname,
                credentials: {
                    password: passwordHash,
                },
            };

            repo.create(user)
                .then((user) => resolve(user))
                .catch((err) => reject(err));
        });
    }

    public static findUser({id, email, nickname}: {id?: string; email?: string; nickname?: string}): Promise<mongoose.Document> {
        const params = {};

        if (id) { params["_id"] = id; }
        if (email) { params["email"] = email; }
        if (nickname) { params["nickname"] = nickname; }
        return new Promise((resolve, reject) => {
            const repo = new UserRepository();
            repo.findOne({...params}).exec()
                .then((doc) => resolve(doc))
                .catch((err) => reject(err));
        });
    }

    public static findOne(cond: Object, fields: Object): Promise<mongoose.Document> {
        const repo = new UserRepository();
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

    public static deleteUser(id: string): Promise<void> {
        const repo = new UserRepository();
        return repo.delete(id);
    }

    private _userModel: UserModelType;

    constructor(userModel: UserModelType) {
        this._userModel = userModel;
    }

    public setTokenInfo(info: {token: string, refreshToken: string}) {
        this._userModel.credentials.tokenInfo = info;
        return this._userModel.save();
    }
}

export class UserRepository extends RepositoryBase<UserModelType> {

    constructor() {
        super(UserSchema);
    }
}
