import mongoose from "mongoose";
import { resolveCname } from "dns";
import { MatchRepository } from "./match";

export interface IRead<T> {
    retrieve: () => Promise<any>;
    findById: (id: string) => Promise<mongoose.Document>;
    findOne(cond ? : Object, callback ? : (err: any, res: T) => void): mongoose.DocumentQuery<mongoose.Document, mongoose.Document, {}> ;
    find(cond: Object, fields: Object, callback ? : (err: any, res: T[]) => void): mongoose.DocumentQuery<mongoose.Document[], mongoose.Document, {}> ;
}

export interface IWrite<T> {
    create: (item: T) => Promise<mongoose.Document>;
    update: (_id: mongoose.Types.ObjectId, item: T) => Promise<T>;
    findByIdAndUpdate: (_id: string, doc: any) => Promise<mongoose.Document>;
    delete: (_id: string) => Promise<void>;
}

export class RepositoryBase<T extends mongoose.Document> implements IRead<T> , IWrite<T> {

    private _model: mongoose.Model<mongoose.Document> ;

    constructor(schemaModel: mongoose.Model<mongoose.Document> ) {
        this._model = schemaModel;
    }

    create(item: Partial<T>): Promise<mongoose.Document> {
        return this._model.create(item);
    }

    retrieve(): Promise<mongoose.Document[]> {
        return new Promise((resolve, reject) => {
            this._model.find({}, (err, items) => {
                if (err) {
                    reject(err);
                    return;
                }
                resolve(items);
            });
        })
    }

    update(_id: mongoose.Types.ObjectId, item: T): Promise<T> {
        return new Promise((resolve, reject) => {
                this._model.update({ _id }, item, (err, item) => {
                    if (err) {
                        reject(err);
                        return;
                    }
                    resolve(item);
                });
            });
    }

    findByIdAndUpdate(_id: string, doc: any): Promise<mongoose.Document> {
        return new Promise((resolve, reject) => {
            this._model.findOneAndUpdate({_id: this.toObjectId(_id)}, doc, (err, item) => {
                if (err) {
                    reject(err);
                    return;
                }
                resolve(item);
            })

        });
    }

    delete(_id: string): Promise<void> {
        return new Promise((resolve, reject) => {
            this._model.remove({
                _id: this.toObjectId(_id)
            }, (err) => {
                if (err) {
                    reject(err);
                    return;
                }
                resolve();
            });
        });
    }

    findById(_id: string): Promise<mongoose.Document> {
        return new Promise((resolve, reject) => {
            this._model.findById(_id, (err, item) => {
                if (err) {
                    reject(err);
                    return;
                }
                resolve(item);
            });
        })
    }

    findOne(cond?: Object, callback?: (err: any, res: T) => void): mongoose.DocumentQuery<mongoose.Document, mongoose.Document, {}> {
        return this._model.findOne(this.castId(cond), callback);
    }

    find(cond?: Object, fields?: Object, callback?: (err: any, res: T[]) => void): mongoose.DocumentQuery<mongoose.Document[], mongoose.Document, {}> {
        return this._model.find(this.castId(cond), fields, callback);
    }

    private toObjectId(_id: string): mongoose.Types.ObjectId {
        return mongoose.Types.ObjectId.createFromHexString(typeof _id === "string" ? _id : String(_id));
    }

    private castId(obj?: Object) {
        if (!obj || !obj["_id"] || obj["_id"] instanceof Object) return obj;
        obj["_id"] = this.toObjectId(obj["_id"]);
        return obj;
    }

}