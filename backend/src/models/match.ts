import mongoose, {Schema} from "mongoose";
import moment from "moment";
import { RepositoryBase } from "./model_base";

const validateDates = (dates: {start: Date, end: Date}) => {
    const {start, end} = dates;
    const now = moment();
    return moment(start).isAfter(now) &&
        moment(end).isAfter(moment(start));
}

export interface PlainMatch {
    _id: string;
    name: string;
    description?: string;
    confirmed: boolean;
    ownerId: string;
    players: string[];
    createdAt: Date;
    startTime: Date;
    endTime: Date;
    isPrivate: boolean;
}

// could not extend mongoose.Document and PlainMatch due to _id conflict so here we are copying
export interface MatchModelType extends mongoose.Document {
    _id: string;
    name: string;
    description?: string;
    password?: string;
    confirmed: boolean;
    ownerId: string;
    players: string[];
    createdAt: Date;
    startTime: Date;
    endTime: Date;
}

const schema = new Schema({
    name: {
        type: String,
        required: true,
        minlength: 4,
        maxlength: 50
    },
    description: {
        type: String
    },
    password: {
        type: String,
        minlength: 4,
        maxlength: 32
    },
    confirmed: {
        type: Boolean,
        default: false
    },
    ownerId: {
        type: Schema.Types.ObjectId,
        required: true
    },
    players: {
        type: [
            {
                type: Schema.Types.ObjectId,
            }
        ],
        default: []
    },
    startTime: {
        type: Date,
        required: true
    },
    endTime: {
        type: Date,
        required: true
    }
})

schema.pre("validate", function<MatchModelType>(next) {
    const start = moment(this.startTime);
    const end = moment(this.endTime);
    const now = moment();
    if (!(start.isAfter(now) && end.isAfter(start))) {
        next(new Error("end time must follow start time and both must be in the future"));
    } else {
        next();
    }

});

export const MatchSchema = mongoose.model<MatchModelType>("match", schema, "matches");

export interface CreateMatchType {
    name: string;
    description?: string;
    password?: string;
    ownerId: string;
    startTime: Date;
    endTime: Date;
}

export class MatchModel {
    
    private _matchModel: MatchModelType;

    constructor(matchModel: MatchModelType) {
        this._matchModel = matchModel;
    }

    get id(): string {
        return this._matchModel._id;
    }

    get name(): string {
        return this._matchModel.name;
    }
    
    get description(): string {
        return this._matchModel.description;
    }

    get password(): string {
        return this._matchModel.password;
    }

    get ownerId(): string {
        return this._matchModel.ownerId;
    }

    get players(): string[] {
        return this._matchModel.players;
    }

    get createdAt(): Date {
        return this._matchModel.createdAt;
    }

    get startTime(): Date {
        return this._matchModel.startTime;
    }

    get endTime(): Date {
        return this._matchModel.endTime;
    }

    get plainMatch(): PlainMatch {
        const {
            _id,
            name,
            description,
            confirmed,
            ownerId,
            players,
            createdAt,
            startTime,
            endTime
        } = this._matchModel;

        return {
            _id,
            name,
            description,
            confirmed,
            ownerId,
            players,
            createdAt,
            startTime,
            endTime,
            isPrivate: !!this._matchModel.password
        };
    }
    
    confirm() {
        this._matchModel.confirmed = true;
        return this._matchModel.save();
    }

    enrollUser(userId: string): Promise<mongoose.Document> {
        return new Promise((resolve, reject) => {
            this._matchModel.update({ $addToSet: {players: userId}}).exec((err, item) => {
                if (err) {
                    reject(err);
                    return;
                }
                resolve(item);
            })
        });
    }

    derollUser(userId: string): Promise<mongoose.Document> {
        return new Promise((resolve, reject) => {
            this._matchModel.update({$pull: {players: userId}}).exec((err, item) => {
                if (err) {
                    reject(err);
                    return;
                }
                resolve(item);
            })
        });
    }
    
    static createMatch(params: CreateMatchType): Promise<mongoose.Document> {
        return new Promise((resolve, reject) => {
            let repo = new MatchRepository();

            let match: Partial<MatchModelType> = {
                ...params
            }

            repo.create(match)
                .then(match => resolve(match))
                .catch(err => reject(err));
        });
    }

    static findMatch(id: string): Promise<mongoose.Document> {
        return new Promise((resolve, reject) => {
            let repo = new MatchRepository();
            repo.findById(id)
                .then(doc => resolve(doc))
                .catch(err => reject(err));
        });
    }
    
}

export class MatchRepository extends RepositoryBase<MatchModelType> {

    constructor() {
        super(MatchSchema);
    }
}
