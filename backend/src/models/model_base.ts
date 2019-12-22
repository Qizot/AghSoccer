import mongoose from "mongoose";
import { resolveCname } from "dns";

export interface IRead<T> {
    retrieve: () => Promise<any>;
    findById: (id: string) => Promise<mongoose.Document>;
    findOne(cond ? : Object, callback ? : (err: any, res: T) => void): mongoose.DocumentQuery<mongoose.Document, mongoose.Document, {}> ;
    find(cond: Object, fields: Object, options: Object, callback ? : (err: any, res: T[]) => void): mongoose.DocumentQuery<mongoose.Document[], mongoose.Document, {}> ;
}

export interface IWrite<T> {
    create: (item: T) => Promise<mongoose.Document>;
    update: (_id: mongoose.Types.ObjectId, item: T) => Promise<T>;
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
                this._model.update({
                _id: _id
            }, item, (err, item) => {
                if (err) {
                    reject(err);
                    return;
                }
                resolve(item);
            });
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
        return this._model.findOne(cond, callback);
    }

    find(cond?: Object, fields?: Object, options?: Object, callback?: (err: any, res: T[]) => void): mongoose.DocumentQuery<mongoose.Document[], mongoose.Document, {}> {
        return this._model.find(cond, options, callback);
    }

    private toObjectId(_id: string): mongoose.Types.ObjectId {
        return mongoose.Types.ObjectId.createFromHexString(_id);
    }

}